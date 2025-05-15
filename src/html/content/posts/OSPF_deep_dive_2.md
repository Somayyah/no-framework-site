---
title: "OSPF Deep Dive - 2"
date: 2024-12-26
description: "About Tables and Packet types and LSAs"
type: "post"
tags: ["OSPF", "Networking", "Routing Protocols", "Cisco", "Protocols", "TCP/IP", "Networking Basics", "Routing", "IP Routing", "Internet Protocols", "Network Security"]
---

> Rest of the OSPF posts can be viewed [**here**](https://techwebunraveled.xyz/tags/ospf/).

In this post, we'll break down the core tables and packet types used in OSPF, which are crucial for understanding how OSPF routers communicate and maintain network topology. I used [rfc2328](http://www.faqs.org/rfcs/rfc2328.html) in writing this post.


## OSPF Tables

### Neighbor Table

This table contains information about the directly connected OSPF routers and their adjacency states. You can view this table using the following command:

```bash
Router1# show ip ospf neighbor

Neighbor ID     Pri   State           Dead Time   Address         Interface
192.168.1.2      1    FULL/DR         00:00:37    10.1.1.2        GigabitEthernet0/0
192.168.1.3      1    FULL/BDR        00:00:33    10.1.1.3        GigabitEthernet0/0
192.168.1.4      1    2WAY/DROTHER    00:00:39    10.1.1.4        GigabitEthernet0/0
```

The output above displays the current OSPF neighbors for Router1, including their state, priority, and connected interfaces. This information is essential for verifying OSPF adjacency and troubleshooting routing issues.

From Router2's perspective, the output might look like this:

```bash
Router2# show ip ospf neighbor

Neighbor ID     Pri   State           Dead Time   Address         Interface
192.168.1.1      1    FULL/DR         00:00:37    10.1.1.1        GigabitEthernet0/0
192.168.1.3      1    FULL/BDR        00:00:33    10.1.1.3        GigabitEthernet0/0
192.168.1.4      1    2WAY/DROTHER    00:00:39    10.1.1.4        GigabitEthernet0/0
```

Explanation:

* **192.168.1.2 (Router1)** is in the `FULL/DR` state from Router1’s perspective, indicating it is the Designated Router (DR) on the network.
* **192.168.1.3 (Router3)** is in the `FULL/BDR` state from Router2’s perspective, meaning Router3 is the Backup Designated Router (BDR).
* **192.168.1.4 (Router4)** is in the `2WAY/DROTHER` state, indicating it is a non-DR/BDR neighbor (DROTHER) and is not involved in the DR/BDR election process.

As a link-state routing protocol, OSPF maintains awareness of all routers in the network topology but forms neighborships only with directly connected routers.

### Topology Table

This table is also known as LSDB (Link state database), which contains all the information OSPF knows about, and each entry in this database is called an LSA (Link state advertisement). We can view it's information using the below command:

```bash
Router# show ip ospf database

            OSPF Router with ID (1.1.1.1) (Process ID 1)

                Router Link States (Area 0)

Link ID         ADV Router      Age     Seq#       Checksum Link count
2.2.2.2         2.2.2.2         120     0x8000002A 0x00A5F2 3
3.3.3.3         3.3.3.3         110     0x8000002B 0x00C5F3 2
1.1.1.1         1.1.1.1         80      0x8000002C 0x00E5F4 4

                Net Link States (Area 0)

Link ID         ADV Router      Age     Seq#       Checksum
192.168.1.1     1.1.1.1         180     0x80000020 0x009F12
192.168.1.2     2.2.2.2         200     0x80000021 0x00BF23

                Summary Net Link States (Area 0)

Link ID         ADV Router      Age     Seq#       Checksum
10.1.1.0        3.3.3.3         360     0x80000035 0x00DF35
10.2.2.0        3.3.3.3         340     0x80000036 0x00FF46

                AS External Link States

Link ID         ADV Router      Age     Seq#       Checksum
0.0.0.0         4.4.4.4         400     0x80000012 0x0012F8
172.16.1.0      4.4.4.4         320     0x80000013 0x0013E8

```

All routers within the same area should have the same copy of this table.

### Routing Table

The router's routing table, which isn't only for OSPF, because just like other protocols OSPF contributes it's best routes from the topology table to it. It's not an OSPF function but rather the native routing table which the router uses to decide where to forward packets, below is an example of such table:

```bash
Here’s an example output for the `show ip route` command:

```bash
Router# show ip route
Codes: C - connected, S - static, R - RIP, M - mobile, B - BGP
       D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2
       i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1
       L2 - IS-IS level-2, ia - IS-IS inter area, * - candidate default
       U - per-user static route, o - ODR, P - periodic downloaded static route

Gateway of last resort is not set

     10.0.0.0/8 is variably subnetted, 6 subnets, 2 masks
C       10.1.1.0/24 is directly connected, FastEthernet0/0
O       10.2.2.0/24 [110/2] via 192.168.1.2, 00:00:15, FastEthernet0/1
O IA    10.3.3.0/24 [110/3] via 192.168.1.3, 00:00:12, FastEthernet0/1
S       10.4.4.0/24 [1/0] via 192.168.1.4

     192.168.0.0/16 is variably subnetted, 3 subnets, 2 masks
C       192.168.1.0/24 is directly connected, FastEthernet0/1
O       192.168.2.0/24 [110/1] via 10.1.1.2, 00:00:20, FastEthernet0/0

     172.16.0.0/16 is variably subnetted, 2 subnets, 1 mask
O E2    172.16.1.0/24 [110/20] via 192.168.1.5, 00:00:25, FastEthernet0/1
C       172.16.2.0/24 is directly connected, Loopback0

```

## OSPF Packets

An OSPF packet starts with a standard 24 byte header, consider below format which is taken from the [RFC](http://www.faqs.org/rfcs/rfc2328.html) :

```goat
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|   Version #   |     Type      |         Packet length         |
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
```

The first byte specifies the OSPF version, while the second byte specifies the packet type as per below:

```goat
Type   Description
________________________________

1      Hello
2      Database Description
3      Link State Request
4      Link State Update
5      Link State Acknowledgment
```

Now let's discuss the packets types:

### Hello

Hello packets are OSPF packet type 1, they're sent periodically on all interfaces (including virtual links) to establish and maintain neighbor relationships.  Hello Packets are multicasted with the IP address 224.0.0.5.

All routers must agree on some parameters which are included in Hello packets, otherwise a neighbor relationships won't form. The hello packet format would typically be as follows:

**Hello packet structure**

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

**Key parameters**

+ Network mask: The network mask associated with the interface. 
+ HelloInterval: The duration in seconds between the Hello packets.
+ Rtr Pri : The router's Router Priority.  Used in (Backup) Designated router election.  If set to 0, the router will be ineligible to become (Backup) Designated Router.
+ RouterDeadInterval: The duration before declaring a silent router down.
+ Designated Router: The identity of the Designated Router for this network, identified by its IP interface address on the network. If there is no DR its set to 0.0.0.0
+ Backup Designated Router: The identity of the Backup Designated Router for this network, identified by its IP interface address on the network.If there is no BDR then it's set to 0.0.0.0.
+ Neighbor: The Router IDs of each router from whom valid Hello packets have been seen recently on the network. Recently means in the last RouterDeadInterval seconds.

Hello Packets are sent periodically to the multicast address 224.0.0.5 which is reserved for OSPF routers, when OSPF is configured the router starts listening / broadcasting on this address which is how OSPF routers discover each other.
The content of a hello packet determines if an adjacency will form or just a neighborship, the difference between an adjacency and neighborship will be explained in another lesson, so for now think of a neighborship as a basic connection between routers, while adjacency involves a deeper, more synchronized relationship where routers exchange LSAs.

Below diagram shows Hello packets exhcanged between routers, OSPF is configured on routers R1 and R2 and R5, so we see bidirectional hello packets between these routers, R1 keeps sending Hello packets to R4 and R5 but since they don't ahve OSPF configured we see that they silently drop them, and R1 will keep sending hello packets regardless depending on the hello interval

![](/svg/assets/Hello1.drawio.svg)

![](/svg/assets/Hello2.drawio.svg)

### Database Description (DBD)

Database Description packets (OSPF Packet Type 2) contain a summary of the Link-State Advertisements (LSAs) in the router's LSDB. Rather than sending the full LSDB, which contains all of the OSPF-related topology information, routers exchange a summarized version of the LSAs. This improves efficiency, especially in scenarios where routers may already have parts of the LSDB.

DBDs are exchanged during the initialization of an OSPF adjacency to compare the LSDBs between two routers. Multiple DBD packets may be exchanged during this process. One router assumes the "master" role, and the other is the "slave." The master sends DBD packets (polls), and the slave responds with DBD packets (responses). The packets are sequenced using the DD sequence numbers to ensure proper order.

#### DBD Packet Structure

```goat
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|   Version #   |       2       |         Packet length         |
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
|         Interface MTU         |    Options    |0|0|0|0|0|I|M|MS|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     DD sequence number                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+-                                                             -+
|                                                               |
+-                      An LSA Header                          -+
|                                                               |
+-                                                             -+
|                                                               |
+-                                                             -+
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                              ...                              |
```

**Key Fields**
- **Interface MTU**: The maximum transmission unit of the interface.
- **Options**: Optional capabilities supported by the router (refer to RFC Section A.2).
- **I-bit (Init bit)**: Indicates this is the first packet in the sequence of DBDs.
- **M-bit (More bit)**: Set to 1 if there are more DBD packets to follow.
- **MS-bit (Master/Slave bit)**: Indicates whether the router is the master (1) or slave (0) during the exchange.
- **DD Sequence Number**: A unique sequence number used to identify and order DBD packets.
- **LSA Header**: A summarized version of an LSA, which includes the LSA's link-state information (but not the full LSA).

In this diagram, Router R1 informs Router R2 of a newly connected router (R5) by summarizing the related LSAs in a DBD packet:

![](/svg/assets/DBD1.drawio.svg)

### Link State Request (LSR)

Link State Request packets are OSPF packet type 3. After exchanging DBD packets with a neighbor, a  router may find that parts of its link-state database are out-of-date or unknown. The LSR packet is used to request more up-to-date information and multiple Link State Request packets may be needed.

A router that sends a Link State Request packet has in mind the precise instance of the database pieces it is requesting. Each
instance is defined by its **LS sequence number**, **LS checksum**, and **LS age**, although these fields are not specified in the Link State Request Packet itself. 

**LSR Packet Structure**
```goat
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|   Version #   |       3       |         Packet length         |
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
|                          LS type                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Link State ID                           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     Advertising Router                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
|                              ...                              |
```

LSAs are requested by specifying the LS type, Link State ID, and Advertising Router. This uniquely identifies the LSA, but not its
instance. Link State Request packets are understood to be requests for the most recent instance (whatever that might be).

per the below diagram we see that R2 is unaware of R5 information which it received via R1, so it sends a request for the R5 entry from R1:

![](/svg/assets/DBD2.drawio.svg)

### Link State Update (LSU)

Link State Update packets are OSPF packet type 4, and each packet carries a collection of LSAs one hop further from their origin, and several LSAs may be included in a single packet. These packets are multicast the physical networks that support multicast/broadcast containing LSAs, which are acknowledged in Link State acknowledgment packets. If retransmission of certain LSAs is necessary, the retransmitted LSAs are always sent directly to the neighbor (not as a multicast!).

**LSU Packet format**

```goat
        0                   1                   2                   3
        0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |   Version #   |       4       |         Packet length         |
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
       |                            # LSAs                             |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                                                               |
       +-                                                            +-+
       |                             LSAs                              |
       +-                                                            +-+
       |                              ...                              |
```

R1 now sends an update which contains the LSA so R2 can populate it's LSDB, which is shown in the below diagram:

![](/svg/assets/DBD3.drawio.svg)

### Link State Acknowledgement (LSAck)

Link State Acknowledgment Packets are OSPF packet type 5, used to explicitly acknowledge LSAs otherwise they won't be reliable and mltiple LSAs can be acknowledged in a single Link State Acknowledgment packet.  

Depending on the state of the sending interface and the sender of the corresponding Link State Update packet, a Link State Acknowledgment packet is sent either to the multicast address AllSPFRouters, to the multicast address AllDRouters, or as a unicast. 

```goat
        0                   1                   2                   3
        0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |   Version #   |       5       |         Packet length         |
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
       |                                                               |
       +-                                                             -+
       |                                                               |
       +-                         An LSA Header                       -+
       |                                                               |
       +-                                                             -+
       |                                                               |
       +-                                                             -+
       |                                                               |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                              ...                              |
```

Now since R2 accepted the LSU, it acknowledges R1's efforts with an LSACK message!

![](/svg/assets/DBD4.drawio.svg)

LSAs will be explained extensively in the next post, for now let's learn about how an LSDP is update once a new LSA is received.

## How the LSDB is Updated

The Link-State Database (LSDB) is updated whenever a new Link-State Advertisement (LSA) is received. To understand how this happens, we must first examine the LSA header, as its fields play a critical role in determining whether the LSA should be added to or replace an entry in the LSDB.

Every LSA begins with a 20-byte header that contains fields essential for identifying, validating, and comparing LSAs:

```goat
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|            LS age             |    Options    |    LS type    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Link State ID                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     Advertising Router                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     LS sequence number                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         LS checksum           |             length            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

### Key Fields in the LSA Header

- **LS Age**:  
  Tracks the time (in seconds) since the LSA was originated.  
  - Initially set to 0 when created and incremented as it propagates across the network.  
  - At every hop, an additional increment (based on the configurable `InfTransDelay`) accounts for transmission delays.  
  - LS Age continues to increase as the LSA resides in each router's LSDB and is capped at a default maximum value of 3600 seconds (`MaxAge`).  
  - When LS Age reaches `MaxAge`:
    - The LSA is marked as stale and invalid.  
    - The router floods the stale LSA with LS Age set to `MaxAge` to flush it from the OSPF domain.  
    - Routers receiving the `MaxAge` LSA remove it from their LSDB and propagate the purge.  

- **Options**:  
  Indicates optional OSPF capabilities supported by the router.  

- **LS Type**:  
  Specifies the type of LSA being advertised. Each LSA type serves a different purpose in the OSPF topology. For example:
  ```goat
  LS Type   Description
  ___________________________________

  1         Router-LSAs
  2         Network-LSAs
  3         Summary-LSAs (IP network)
  4         Summary-LSAs (ASBR)
  5         AS-external-LSAs
  ```

- **Link State ID**:  
  Uniquely identifies the LSA based on its type. For example:
  - For a Network-LSA, this is the IP address of the Designated Router (DR) on the network.  

- **Advertising Router**:  
  Identifies the router that originated the LSA using its Router ID.  

- **LS Sequence Number**:  
  A 32-bit signed integer used to track the version of the LSA.  
  - Higher sequence numbers indicate newer LSAs.  
  - Sequence numbers range from `0x80000001` (InitialSequenceNumber) to `0x7FFFFFFF` (MaxSequenceNumber).  
  - If a router receives an LSA with:
    - **Higher sequence number**: The LSDB is updated with the newer LSA.  
    - **Lower or equal sequence number**: The LSA is ignored, as it is stale or a duplicate.  

- **LS Checksum**:  
  Ensures the integrity of the LSA's content (excluding LS Age).  
  - Routers calculate the checksum upon receiving an LSA to verify that it was not corrupted during transmission.  
  - Any mismatch invalidates the LSA.  

- **Length**:  
  Specifies the size of the LSA in bytes, including the 20-byte header.  

### LSDB Update Process

When a router receives a new LSA, it performs the following steps to determine if the LSDB needs to be updated:

1. **Identify the LSA**:  
   The router uses the `LS Type`, `Link State ID`, and `Advertising Router` fields to locate the corresponding entry in its LSDB.  

2. **Validate the LSA**:  
   - The router compares the incoming LSA's `LS Sequence Number`, `LS Age`, and `LS Checksum` with the existing entry in the LSDB:  
     - **Newer LSA (higher sequence number)**: The LSDB is updated, and the LSA is flooded to neighbors.  
     - **Duplicate or older LSA (lower or equal sequence number)**: The LSA is ignored.  
     - **Corrupted LSA (checksum mismatch)**: The LSA is discarded.  

3. **Flood the LSA**:  
   If the LSA is accepted as valid and newer, the router forwards it to its OSPF neighbors, ensuring synchronization across the network.  

By examining and comparing these fields, OSPF ensures that each router maintains an accurate and synchronized view of the network topology.

In the next post, we will understand how neighborships and adjacencies are formed and how to distinguish of them.