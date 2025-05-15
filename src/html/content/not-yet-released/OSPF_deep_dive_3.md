---
title: "OSPF Deep Dive - 3"
date: 2024-12-26
description: "About adjacencies and neighborships"
type: "post"
tags: ["OSPF", "Networking", "Routing Protocols", "Cisco", "Protocols", "TCP/IP", "Networking Basics", "Routing", "IP Routing", "Internet Protocols"]
---

## Introduction

Today we will learn about OSPF neighborships and adjacencies and how they differ from each other. OSPF has to get through 7 states in order to become neighbors…here they are:

1. Down: no OSPF neighbors yet.
2. Init: Hello packet received.
3. Two-way: own router ID found in received hello packet.
4. Exstart: master and slave roles determined.
5. Exchange: database description packets (DBD) are sent.
6. Loading: exchange of LSRs (Link state request) and LSUs (Link state update) packets.
7. Full: OSPF routers now have an adjacency

The figure below is taken from the OSPF v2 RFC showing the transition between them: 

```goat
                        +----+
                        |Down|
                        +----+
                            |\
                            | \Start
                            |  \      +-------+
                    Hello   |   +---->|Attempt|
                   Received |         +-------+
                            |             |
                            |             | Hello
                +------+<---+             | Received
                | Init |<-----------------+
                +---+--+<------------+
                    |                |
                    | 2-Way          | 1-Way
                    | Received       | Received
                    |                |
    +-------+       |             +--+--+
    |ExStart|<------+------------>|2-Way|
    +-------+                     +-----+

    Figure 1: Neighbor State Changes (Hello Protocol)
```

## Terms Of Agreement

Before we start with the stages one by one let's take a look at the OSPF Hello packet header:

```goat
        0                   1                   2                   3
        0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |   Version #   |       1       |         Packet length         |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                          Router ID                            |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                           Area ID                             |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |           Checksum            |             AuType            |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                       Authentication                          |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                       Authentication                          |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                        Network Mask                           |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |         HelloInterval         |    Options    |    Rtr Pri    |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                     RouterDeadInterval                        |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                      Designated Router                        |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                   Backup Designated Router                    |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                          Neighbor                             |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                              ...                              |
```

Before any two routers become neighbors the below parameters should match:
+ Version
+ Area ID
+ Authentication
+ Network Mask
+ RouterDeadInterval
+ HelloInterval

## States
### DOWN State

The **Down** state is the initial state of a neighbor relationship in OSPF, indicating that no Hello packets have been exchanged between routers yet. While in this state, Hello packets may still be sent, but no communication has been established with the neighbor.

The **Down** state can be triggered by the following events:

- **KillNbr**: Explicitly removes the neighbor relationship, forcing the state to transition to Down.
- **InactivityTimer**: If no Hello packets are received from the neighbor within the **Dead Interval** (default: 4 times the Hello Interval), the neighbor moves to the Down state.
- **LLDown**: If the link-local address of the neighbor goes down, the state transitions to Down.
- **Manual Removal**: If a neighbor is manually removed from the OSPF configuration, it will be set to Down.

These events ensure that the router recognizes when a neighbor relationship has failed or been removed and they can be received in any stage.

```goat
                                               Hello?                                                            
                                                                                                                 
                                               Source IP: 2.2.2.2                                                
                                               Dest IP: 224.0.0.5                                                
                                               Neighbors: Jake, Layla                                            
                             +------------------------+                                 +-----------------------+
                             |                        |                                 |                       |
                             |      Alice / DOWN      |---------------------------------|      Bob / DOWN       |
                             |         2.2.2.2        |              Hello?             |        1.1.1.1        |
                             |                        |                                 |                       |
                             +------------------------+              Source IP: 1.1.1.1 +-----------------------+
                                                                     Dest IP: 224.0.0.5                          
                                                                     Neighbors: Non                              
```

In the diagram above, both Alice and Bob can send Hello packets, but they yet to receive one from another router, since no neighborships are formed yet they will be in **DOWN** state.

### INIT State

In this state the router has just received a hello packet from a neighbor, but the receiving router ID was not included in the hello packet, consider below:

```goat
                                                                                                                                    
                                 Hello Anyone here?     |                                                                           
                                                        |                                                                           
                                 Source IP: 2.2.2.2     |                              I don't know this router and my ID           
                                 Dest IP: 224.0.0.5     | ---\                         isn't in the Neighbor's field                
                                 Neighbors: Jake, Layla |     -----\                   I'll respond with a hello to become neighbors
                                                        +           -----\                                                          
             +------------------------+                                   -----\      +------------------------+                    
             |                        |                                         -->   |                        |                    
             |      Alice             |                                               |                        |                    
             |                        |---------------------------------------------- |        Bob             |                    
             |        2.2.2.2         |                                               |                        |                    
             |                        |                                               |          1.1.1.1       |                    
             +------------------------+                                               +------------------------+                    
```

When Bob receives the hello packet from Alice, it checks the neighbors list, since it's ID isn't included in it then Alice is a router that Bob doesn't know about yet and they are not neighbors, to form the neighbor relationship Bob responds with it's own hello, adding Alice ID to the neighbors field:

```goat
                                                                  | Hello                       
                                                                  |                             
                                                              ----| From: 1.1.1.1               
                                                  -----------/    | To: 224.0.0.5               
                                          -------/                | Neighbors: 2.2.2.2          
                                 --------/                        +------------                           
+------------------------+ <----/                                        +------------------------+
|                        |                                               |                        |
|      Alice             |                                               |       Bob              |
|                        |---------------------------------------------- |                        |
|         2.2.2.2        |                                               |         1.1.1.1        |
|                        |                                               |                        |
+------------------------+                                               +------------------------+
```

Alice now knows about Bob, and interprets it's hello packet as an acknowledgement and agreement to becoming neighbors.

### TWO-WAY State

In this state, the communication is now bidirectional which has been assured by the Hello Protocol. This is the most advanced state short of beginning adjacency establishment, as the routers are neighbors but adjacency hasn't formed yet. The DR / BRD are elected in this step or greater.

### ExStart State

The goal of this step:
+ Decide which router is the master were the router with teh highest router ID becomes the master.
+ decide upon the initial DD sequence number.

Since Alice's ID is 2.2.2.2 and it's higher than Bob's, it will be the master:

```goat
                                                                                                                 
        Since I have the highest    |                                              
        router ID I'll be the master|--\                                           
                                    |   ---\                                       
        Deal?              ---------+       ----\                                  
+------------------------+                        ---\     +-----------------------+
|                        |                            -->  |                       |
|          Alice         |--------- ExStart State ---------|           Bob         |
|         2.2.2.2        |                                 |         1.1.1.1       |
|                        |                                 |                       |
+------------------------+                                 +-----------------------+                       
```
After this step All the conversations are called adjacencies were routers would exchage the LSDB. We will talk about DR / BDR election later, for now just assume that both routers have elected the DR / BDR.

### ExChange State

After negotiating who is the slave / master in the exstart phase the routers would exchange DBD (Database description packet) as a summary of the LSDB, which will help them find information about networks they don't know about. The master sends the first DBD Packet which is the only part that is retransmittable. The slave can only respond back.

```goat
                                    |                                              
                    Here is my DBD  |--\                                           
                                    |   ---\                                       
                            --------+       ----\                                  
+------------------------+                        ---\     +-----------------------+
|                        |                            -->  |                       |
|          Alice         |--------- ExStart State ---------|           Bob         |
|         2.2.2.2        |  <--                            |         1.1.1.1       |
|                        |     \----                       |                       |
+------------------------+          \----       +--------  +-----------------------+
                                        \----   |                                  
                                            \---| Here is my DBD                   
                                                |                                  
```

### LOADING State



### FULL State