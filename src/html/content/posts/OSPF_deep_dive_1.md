---
title: "OSPF Deep Dive - 1"
date: 2024-12-15
description: “My first tutorial on OSPF, attempting to provide a deep dive - Part 1"
type: "post"
tags: ["OSPF", "Networking", "Routing Protocols", "Cisco", "Protocols", "TCP/IP", "Networking Basics", "Routing", "IP Routing", "Internet Protocols", "Network Security"]
---

> Rest of the OSPF posts can be viewed [**here**](https://techwebunraveled.xyz/tags/ospf/)

[OSPF](https://en.wikipedia.org/wiki/Open_Shortest_Path_First) (Open Shortest Path First) is a [link-state](https://en.wikipedia.org/wiki/Link-state_routing_protocol) routing protocol that's still super relevant in today’s world of networking. I know it can feel a bit overwhelming, but don’t worry – I’ll break it down for you in this blog. We’ll dive into both the theory and the practical side of things, and I’ll try to make it as easy to understand as possible. Hopefully, by the end, you’ll have a solid grasp on OSPF and why it’s so important.

## Introduction

OSPF follows link-state routing principles, meaning that each OSPF-enabled router has a complete map of the network, not just information about its neighbors. This enables efficient path calculation, taking into account metrics like the link bandwidth cost (e.g., 1Gbps, Fast Ethernet, 10Gbps, etc.). The process starts with two OSPF-enabled routers forming a neighborship. After agreeing on a few parameters, they exchange LSAs (Link-State Advertisements) to populate their LSDB (Link-State Database).

Of course, things aren't quite this simple, and there are deeper layers to explore. But hey, we’ve got to start somewhere, right?

<img src="https://cdn.networklessons.com/wp-content/uploads/2013/02/routers-lsdb-lsa.png" style="display: block; margin: 0 auto;" alt="Diagram of OSPF-enabled routers exchanging routing information through LSAs and storing it in their LSDBs" />

<p style="font-size: 16px; text-align: center; background-color: rgba(255, 255, 255, 0.8); padding: 10px; border-radius: 5px;">
  Image source: <a href="https://www.networklessons.com/">NetworkLessons</a>
</p>

## Preventing OSPF Traffic Overload

OSPF operates by routers exchanging LSAs (Link-State Advertisements) and using them to populate their Link-State Database (LSDB). You may have already noted a potential issue: since each router contains information about all the other routers in the network, wouldn't there be a risk of flooding if routers continuously initiate LSAs? If there are too many OSPF routers, could the exchange of these LSAs overwhelm the network? Yes, this can happen. 

<img src="https://cdn.networklessons.com/wp-content/uploads/2013/02/ospf-full-mesh.png" style="display: block; margin: 0 auto;" alt="Diagram of LSA storm" />

<p style="font-size: 16px; text-align: center; background-color: rgba(255, 255, 255, 0.8); padding: 10px; border-radius: 5px;">
  Image source: <a href="https://www.networklessons.com/">NetworkLessons</a>
</p>

To address this, solutions like the introduction of area hierarchies are used. In the case of a single-area OSPF network, routers elect a **Designated Router (DR)**, where all other routers send their LSAs. The DR then forwards the LSAs to other routers, avoiding the need for each router to send LSAs to every other router.

This approach prevents OSPF traffic from becoming a mesh-like situation, making the network more efficient and less CPU-intensive. As a backup we also elect **Backup designated router (BDR)** in case the original one crashes.

## Shortest-path first (SPF) algorithm

OSPF uses [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm) to determine the best route between two destinations, then updates its **routing table** with the best paths. The LSDB serves as the database used by the SPF algorithm to compute these paths.

OSPF uses the concept of areas, think of it as a heirarchy the default area is Area 0 (the backbone) and every other area has to connect to it.

![An image of a multi area network, showing the backbone area 0 and two other areas, both areas have to connect to Area 0 through an area border router ABR](/svg/assets/OSPF%20AREAS_11zon.webp)

Area 0 is mandatory and other areas have to connect to it through an **area border router (ABR)**, also, it's possible to import routes from other domains that use other routing protocols like [RIP](https://en.wikipedia.org/wiki/Routing_Information_Protocol) or [EIGRP](https://en.wikipedia.org/wiki/Enhanced_Interior_Gateway_Routing_Protocol) or [IS-IS](https://en.wikipedia.org/wiki/IS-IS) through a process called **Redistribution**, and routers that connect an OSPF area to a domain using another routing protocol are called **Autonomous system border routers ASBR**

## OSPF flow

OSPF follows some steps to achieve it's objective, we will go deeper into each step but for now here is an overview:

* Step 1 : Router Initialization
   - OSPF routers are configured with an **OSPF process ID** and network interfaces.
   - **Interface activation**: OSPF needs to be enabled on the interfaces participating in the OSPF routing process.

* Step 2 : Neighbor Discovery
   - **Hello packets** are sent periodically to discover neighboring routers on the same network.
   - These Hello packets contain information like router ID, area ID, and other parameters used to establish adjacency, we will talk about it in later sections.
   - If a router receives a Hello packet from a neighboring router with compatible parameters (e.g., OSPF area, Hello and Dead intervals), an **OSPF adjacency** is formed.
   
* Step 3 : Exchange of Link-State Information
   - Routers exchange **Link-State Advertisements (LSAs)** to share information about the state of their links (interfaces and their status).
   - Each router sends an **LSR (Link-State Request)** to request missing LSAs from a neighbor if it does not have them in its database.
   - The neighbor responds with **LSU (Link-State Update)**, which contains the requested LSAs.

* Step 4 : Building the Link-State Database (LSDB)
   - Routers build and maintain a **Link-State Database** (LSDB) that contains information about all routers in the area and their links.
   - This database is updated when new LSAs are received and processed.

* Step 5 : Shortest Path First (SPF) Calculation
   - Once the LSDB is complete, OSPF uses the **Dijkstra algorithm** (Shortest Path First) to compute the shortest path tree (SPT) based on the LSDB.
   - The result of the SPF calculation is the router’s **routing table**, which contains the best paths to reach each destination.

* Step 6 : Routing Table Update
   - The router updates its **routing table** with the new OSPF routes derived from the SPF algorithm.
   - These routes are used to forward traffic to their destinations based on the shortest path.

* Step 7 : Periodical Updates and LSAs
   - OSPF routers periodically exchange LSAs to keep the network topology updated and ensure routing tables reflect changes in the network (like interface status changes or link failures).
   - LSAs are triggered when there is a change in the network, such as a link going down or coming up.

* Step 8 : Convergence
   - Convergence occurs when all OSPF routers have the same LSDB and routing tables, ensuring all routers have an updated and consistent view of the network.

* Step 9 : Maintaining Neighbor Relationships
   - OSPF routers continually send **Hello packets** to maintain the adjacency.
   - If there’s no response from a neighbor within a set time (Dead interval), the neighbor relationship is considered down, and the router recalculates the routing table.

## Neighbor Discovery

OSPF routers won't exchange LSAs unless they form neighborships, think of it like introducing yourself to one another, routers start with a hello message which contain these parameters:
+ Router ID: An OSPF router has a unique ID representing highest IP address on any active interface.
+ Hello / Dead interval: Have to match on each side, keepalive messages are sent every X seconds, if a router isn't hearing them after the dead interval has elapsed then the neighbor is declared as dead.
+ Neighbors: The neighbors of the router advertising it's LSAs.
+ Area ID: Has to match on both sides to become neighbors.
+ Router priority: Used to determine who will be the DR.
+ DR / BDR IP addresses
+ Authentication Password: has to match on both sides, can be in plain text or MD5, if configured then every packet has to be authenticated with it.
+ Stub area flag : OSPF areas can be of different types.

A **router ID** value will be automatically select the router ID based on the following order of preference:

+ Manually Configured Router ID: If you configure the router ID manually, that value will be used.
+ Highest IP Address on a Loopback Interface: If the router ID isn't manually configured, OSPF will select the highest IP address from the loopback interfaces. Loopback interfaces are preferred because they are always up as long as the router is functioning, making them more stable.
+ Highest IP Address on an Active Physical Interface: If no loopback interfaces are available or configured, OSPF will then select the highest IP address on any active physical interface (such as Ethernet or serial interfaces).

If non are applicable then OSPF will not start, and neighborships will not be formed. Loopbacks are useful because they never go down unless the router crashes.

## Shortest Path First (SPF) Calculation

OSPF uses the SPF algorithm, which is based on Dijkstra's algorithm, here is a table that shows the default OSPF cost (metric) based on interface bandwidth. The formula for OSPF cost is:

**Cost = Reference Bandwidth (100 Mbps by default) ÷ Interface Bandwidth**

| **Interface Bandwidth** | **Default OSPF Cost** |
|--------------------------|-----------------------|
| 100 Gbps                | 1                     |
| 10 Gbps                 | 1                     |
| 1 Gbps                  | 1                     |
| 100 Mbps                | 1                     |
| 10 Mbps                 | 10                    |
| 1 Mbps                  | 100                   |
| 512 Kbps                | 195                   |
| 128 Kbps                | 781                   |
| 64 Kbps                 | 1562                  |
| 56 Kbps                 | 1785                  |


If two paths from the same source to the destination have equal costs, load balancing is used.

In the [next post](../ospf_deep_dive_2/) we will deep dive into path selection and LSAs and how LSDB is populated.