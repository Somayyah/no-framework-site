---
title: "Linux || xxd || How to create and reverse hexdump files"
date: 2024-11-15
description: Using xxd to convert files to hexdump files and revert them back to their original format
type: "post"
tags: ["linux", "unix", "commands", "how-to", "technology", "explain-like-i'm-five", "hacks", "reverse-engineering", "OverTheWire", "hexdump", "gzip", "compression", "bandit-challenge", "bandit"]

---

In this post I aim to explain what and how to interact with hex dump files and to solve a simple challenge to enforce learning.

## What's a hexdump exactly

A [hex dump](https://en.wikipedia.org/wiki/Hex_dump) is a textual representation of data in hexadecimal format, often used for inspecting files or binary data. It's especially useful for debugging and reverse engineering.

However, a hex dump is not the same as a [HEX file format](https://en.wikipedia.org/wiki/Hex_file). Instead, think of a hex dump as a way to view the binary data of a file in hexadecimal form, making it easier to read and analyze.

Below is a sample of a hexdump used in the challenge:

![A snippet of the hexdump of the file data.txt from the bandit 13 challenge ](/svg/assets/carbon.svg "A snippet of the hex dump of data.txt")

The goal is to find the bandit13's password which is hidden in the file data.txt. As per the challenge the main text file has been compressed multiple times and we only have it's hexdump representation.

Usually hex dumps present us with three columns:

```
watari@DESKTOP-PVA8708:~$ hd file.txt
00000000  48 65 6c 6c 6f 20 77 6f  72 6c 64 21 0a 48 65 6c  |Hello world!.Hel|
00000010  6c 6f 20 77 6f 72 6c 64  21 0a 48 65 6c 6c 6f 20  |lo world!.Hello |
00000020  77 6f 72 6c 64 21 0a 48  65 6c 6c 6f 20 77 6f 72  |world!.Hello wor|
00000030  6c 64 21 0a 48 65 6c 6c  6f 20 77 6f 72 6c 64 21  |ld!.Hello world!|
00000040  0a 48 65 6c 6c 6f 20 77  6f 72 6c 64 21 0a 48 65  |.Hello world!.He|
00000050  6c 6c 6f 20 77 6f 72 6c  64 21 0a 48 65 6c 6c 6f  |llo world!.Hello|
00000060  20 77 6f 72 6c 64 21 0a  48 65 6c 6c 6f 20 77 6f  | world!.Hello wo|
00000070  72 6c 64 21 0a 48 65 6c  6c 6f 20 77 6f 72 6c 64  |rld!.Hello world|
00000080  21 0a 48 65 6c 6c 6f 20  77 6f 72 6c 64 21 0a 48  |!.Hello world!.H|
00000090  65 6c 6c 6f 20 77 6f 72  6c 64 21 0a 48 65 6c 6c  |ello world!.Hell|
000000a0  6f 20 77 6f 72 6c 64 21  0a 48 65 6c 6c 6f 20 77  |o world!.Hello w|
000000b0  6f 72 6c 64 21 0a 48 65  6c 6c 6f 20 77 6f 72 6c  |orld!.Hello worl|
000000c0  64 21 0a 48 65 6c 6c 6f  20 77 6f 72 6c 64 21 0a  |d!.Hello world!.|
000000d0
```

In this output, the leftmost column represents the hexadecimal displacement (or address) of the data. Each row displays 16 bytes and the final column shows the corresponding ASCII characters for the hexadecimal values.

To work with and view hex dumps, there are several utilities available, such as xxd, od, and hd. My personal preference is to use hd to review the hexdump content.

## Some Background

Before proceeding with the challenge we need to be familiar with file's [magic numbers](https://www.garykessler.net/library/file_sigs.html) or file signatures, which are the first 3 octets of a file that represent it's type, we can view them using a command like ```hd``` and by refering to the internet you can infer the file type, for example:

```
user@machine$ hd somefile.bz2
00000000  42 5a 68 39 31 41 59 26  53 59 ca 83 b2 c1 00 00  |BZh91AY&SY......|
00000010  17 7f ff df f3 f4 a7 fc  9f fe fe f2 f3 cf fe f5  |................|
00000020  ff ff dd bf 7e 5b fe fa  ff df be 97 aa 6f ff f0  |....~[.......o..|
00000030  de ed f7 b0 01 3b 56 04  00 00 34 d0 00 00 00 00  |.....;V...4.....|
00000040  69 a1 a1 a0 00 03 43 46  86 43 41 a6 80 06 8d 1a  |i.....CF.CA.....|
00000050  69 a0 d0 00 68 d1 a0 19  06 11 93 04 33 51 93 d4  |i...h.......3Q..|
00000060  c6 51 03 46 46 9a 34 00  00 d3 20 06 80 00 03 26  |.Q.FF.4... ....&|
00000070  4d 03 46 86 83 d2 1a 06  86 80 64 34 00 01 89 a6  |M.F.......d4....|
00000080  83 4f d5 01 90 00 1e 90  34 d1 88 03 43 0e 9a 0c  |.O......4...C...|
00000090  40 69 a0 06 26 46 86 83  40 03 10 d3 40 34 69 a6  |@i..&F..@...@4i.|
user@machine$
```

we read the first three octets are **42 5a 68** which means our file is a bzip2 file.

## Understanding xxd command

```xxd``` utility isn't pre-installed on all linux destributions however it's easily installed using default package managers as below:

Ubuntu/Debian based:

```sudo apt install xxd```

Fedora/RHEL based:

```sudo dnf install xxd```

Arch-based distros:

```sudo pacman -S xxd```

With the option -h we can have a brief of this command:

![xxd command  and it's options using -h, the full command is xxd -h](/svg/assets/xxd%20command%20options.svg "The help information of the command xxd")

## Solving a challenge

To solve challenges like [Bandit Level 13](https://overthewire.org/wargames/bandit/bandit13.html), you need to get the hang of hexdumps and how to work with them. This is key to finding the password for the user `bandit13`. After login into the machine with SSH we are presented with a single file:

```
bandit12@bandit:/tmp/tmp.AcTTlQz4nj$ ls
data.txt
```

After viewing it's content we notice that this isn't a regular text file:

```
bandit12@bandit:/tmp/tmp.AcTTlQz4nj$ cat data.txt
00000000: 1f8b 0808 dfcd eb66 0203 6461 7461 322e  .......f..data2.
00000010: 6269 6e00 013e 02c1 fd42 5a68 3931 4159  bin..>...BZh91AY
00000020: 2653 59ca 83b2 c100 0017 7fff dff3 f4a7  &SY.............
00000030: fc9f fefe f2f3 cffe f5ff ffdd bf7e 5bfe  .............~[.
00000040: faff dfbe 97aa 6fff f0de edf7 b001 3b56  ......o.......;V
00000050: 0400 0034 d000 0000 0069 a1a1 a000 0343  ...4.....i.....C
00000060: 4686 4341 a680 068d 1a69 a0d0 0068 d1a0  F.CA.....i...h..
00000070: 1906 1193 0433 5193 d4c6 5103 4646 9a34  .....3Q...Q.FF.4
00000080: 0000 d320 0680 0003 264d 0346 8683 d21a  ... ....&M.F....
00000090: 0686 8064 3400 0189 a683 4fd5 0190 001e  ...d4.....O.....
000000a0: 9034 d188 0343 0e9a 0c40 69a0 0626 4686  .4...C...@i..&F.
000000b0: 8340 0310 d340 3469 a680 6800 0006 8d0d  .@...@4i..h.....
000000c0: 0068 0608 0d1a 64d3 469a 1a68 c9a6 8030  .h....d.F..h...0
000000d0: 9a68 6801 8101 3204 012a ca60 51e8 1cac  .hh...2..*.`Q...
000000e0: 532f 0b84 d4d0 5db8 4e88 e127 2921 4c8e  S/....].N..')!L.
000000f0: b8e6 084c e5db 0835 ff85 4ffc 115a 0d0c  ...L...5..O..Z..
00000100: c33d 6714 0121 5762 5e0c dbf1 aef9 b6a7  .=g..!Wb^.......
00000110: 23a6 1d7b 0e06 4214 01dd d539 af76 f0b4  #..{..B....9.v..
00000120: a22f 744a b61f a393 3c06 4e98 376f dc23  ./tJ....<.N.7o.#
00000130: 45b1 5f23 0d8f 640b 3534 de29 4195 a7c6  E._#..d.54.)A...
00000140: de0c 744f d408 4a51 dad3 e208 189b 0823  ..tO..JQ.......#
00000150: 9fcc 9c81 e58c 9461 9dae ce4a 4284 1706  .......a...JB...
00000160: 61a3 7f7d 1336 8322 cd59 e2b5 9f51 8d99  a..}.6.".Y...Q..
00000170: c300 2a9d dd30 68f4 f9f6 7db6 93ea ed9a  ..*..0h...}.....
00000180: dd7c 891a 1221 0926 97ea 6e05 9522 91f1  .|...!.&..n.."..
00000190: 7bd3 0ba4 4719 6f37 0c36 0f61 02ae dea9  {...G.o7.6.a....
000001a0: b52f fc46 9792 3898 b953 36c4 c247 ceb1  ./.F..8..S6..G..
000001b0: 8a53 379f 4831 52a3 41e9 fa26 9d6c 28f4  .S7.H1R.A..&.l(.
000001c0: 24ea e394 651d cb5c a96c d505 d986 da22  $...e..\.l....."
000001d0: 47f4 d58b 589d 567a 920b 858e a95c 63c1  G...X.Vz.....\c.
000001e0: 2509 612c 5364 8e7d 2402 808e 9b60 02b4  %.a,Sd.}$....`..
000001f0: 13c7 be0a 1ae3 1400 4796 4370 efc0 9b43  ........G.Cp...C
00000200: a4cb 882a 4aae 4b81 abf7 1c14 67f7 8a34  ...*J.K.....g..4
00000210: 0867 e5b6 1df6 b0e8 8023 6d1c 416a 28d0  .g.......#m.Aj(.
00000220: c460 1604 bba3 2e52 297d 8788 4e30 e1f9  .`.....R)}..N0..
00000230: 2646 8f5d 3062 2628 c94e 904b 6754 3891  &F.]0b&(.N.KgT8.
00000240: 421f 4a9f 9feb 2ec9 83e2 c20f fc5d c914  B.J..........]..
00000250: e142 432a 0ecb 0459 1b15 923e 0200 00    .BC*...Y...>...
bandit12@bandit:/tmp/tmp.AcTTlQz4nj$
```

Instead it's a hex dump of the original file, which as per the challenge has been compressed multiple times, and we have to revert it back to the original text file to get user bandit13's password. First let's create a directory under /tmp to keep our work organized and copy the hex dump file there:

```
bandit12@bandit:~$ mktemp -d
/tmp/tmp.ydWoyX3Bw9
bandit12@bandit:~$ cp data.txt /tmp/tmp.ydWoyX3Bw9
bandit12@bandit:~$ cd /tmp/tmp.ydWoyX3Bw9
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ ls
data.txt
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$
```

Next we take a brief look at the ASCII portion of the hex dump, we notice that it starts with ```1f 8b 08``` which is [the magic number](https://www.garykessler.net/library/file_sigs.html) for GZIP archive file:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd data.txt | head
00000000  30 30 30 30 30 30 30 30  3a 20 31 66 38 62 20 30  |00000000: 1f8b 0|
00000010  38 30 38 20 64 66 63 64  20 65 62 36 36 20 30 32  |808 dfcd eb66 02|
00000020  30 33 20 36 34 36 31 20  37 34 36 31 20 33 32 32  |03 6461 7461 322|
00000030  65 20 20 2e 2e 2e 2e 2e  2e 2e 66 2e 2e 64 61 74  |e  .......f..dat|
00000040  61 32 2e 0a 30 30 30 30  30 30 31 30 3a 20 36 32  |a2..00000010: 62|
00000050  36 39 20 36 65 30 30 20  30 31 33 65 20 30 32 63  |69 6e00 013e 02c|
00000060  31 20 66 64 34 32 20 35  61 36 38 20 33 39 33 31  |1 fd42 5a68 3931|
00000070  20 34 31 35 39 20 20 62  69 6e 2e 2e 3e 2e 2e 2e  | 4159  bin..>...|
00000080  42 5a 68 39 31 41 59 0a  30 30 30 30 30 30 32 30  |BZh91AY.00000020|
00000090  3a 20 32 36 35 33 20 35  39 63 61 20 38 33 62 32  |: 2653 59ca 83b2|
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$
```

So this hex dump is of a [GZIP compressed file](https://en.wikipedia.org/wiki/Gzip), let's try to convert it back to the original compressed file to extract it later:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ xxd -r data.txt output.gz
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ ls
data.txt output.gz
```
Now let's extract the new file with the below command:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ gzip -dk output.gz
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ ls
output  data.txt output.gz
```

The file still isn't a human readable text file, and by checking it's magic number we find that it's **42 5A 68** which is for bzip2 compressed archive:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output
00000000  42 5a 68 39 31 41 59 26  53 59 ca 83 b2 c1 00 00  |BZh91AY&SY......|
00000010  17 7f ff df f3 f4 a7 fc  9f fe fe f2 f3 cf fe f5  |................|
00000020  ff ff dd bf 7e 5b fe fa  ff df be 97 aa 6f ff f0  |....~[.......o..|
00000030  de ed f7 b0 01 3b 56 04  00 00 34 d0 00 00 00 00  |.....;V...4.....|
00000040  69 a1 a1 a0 00 03 43 46  86 43 41 a6 80 06 8d 1a  |i.....CF.CA.....|
00000050  69 a0 d0 00 68 d1 a0 19  06 11 93 04 33 51 93 d4  |i...h.......3Q..|
00000060  c6 51 03 46 46 9a 34 00  00 d3 20 06 80 00 03 26  |.Q.FF.4... ....&|
00000070  4d 03 46 86 83 d2 1a 06  86 80 64 34 00 01 89 a6  |M.F.......d4....|
00000080  83 4f d5 01 90 00 1e 90  34 d1 88 03 43 0e 9a 0c  |.O......4...C...|
00000090  40 69 a0 06 26 46 86 83  40 03 10 d3 40 34 69 a6  |@i..&F..@...@4i.|
```

Another compressed file! let's decompress it as below:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ mv output output2.bz2
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ bzip2 -dk output2.bz2
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ ls
output2  output.bz2  output.gz data.txt
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$
```

After extracting it we still don't have a text file:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ head output2
���fdata4.bin��=H[q���赚�� ���Nzor?pb�*��H��U$!J*�A����Z$��֡
AP\���
��JP�1�VEt�H75:Z�I��{��8g{#�xH� ��7G�34�"�.�G;�U�0=f~xM����0���[0<�dY��W�]w��"����ڿ�x��?��:��{�Nmhs����-
_��A<����2�z�,v��T�W��ә��;�د�[����T@l:�:jO��ME��5w�d���~��ៅ�����`�:�u�n9��UTPbandit12@bandit:/tmp/tmp.ydWoyX3Bw9$
```

By checking the hex data of this file we see the magic number still refers to .gz compressed file:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output2 | head
00000000  1f 8b 08 08 df cd eb 66  02 03 64 61 74 61 34 2e  |.......f..data4.|
00000010  62 69 6e 00 ed d1 3d 48  5b 71 14 c6 e1 7f b0 e8  |bin...=H[q......|
00000020  b5 9a 8a a0 20 99 ae 04  92 4e 7a 6f 72 3f 70 10  |.... ....Nzor?p.|
00000030  62 9a 2a 95 bb 48 86 aa  55 24 21 4a 2a f8 41 8c  |b.*..H..U$!J*.A.|
00000040  a2 83 98 14 5a 24 d4 c5  d6 a1 1d 0a 41 50 5c eb  |....Z$......AP\.|
00000050  e8 d0 0a 81 d6 4a 50 d0  31 96 56 45 1c 74 a9 48  |.....JP.1.VE.t.H|
00000060  37 35 3a 5a d0 49 ab f0  7b 86 f3 1e 38 67 7b 23  |75:Z.I..{...8g{#|
00000070  a1 78 48 af 09 bf ec 17  37 47 c9 33 34 ed 22 f3  |.xH.....7G.34.".|
00000080  2e a5 47 3b df 55 cd 30  3d 66 7e 78 4d a1 a8 aa  |..G;.U.0=f~xM...|
00000090  c7 30 85 ac 88 5b 30 3c  14 0f c5 64 59 c4 06 06  |.0...[0<...dY...|
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$
```

So let's decompress it again:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ mv output2 output3.gz
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ gzip -kd output3.gz
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ ls
output3.gz  output2.bz2  output.gz  data.txt
```

Our work isn't done, looks like we need to extract the file multiple times, so again we check the magic number:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output3.gz | head
00000000  64 61 74 61 35 2e 62 69  6e 00 00 00 00 00 00 00  |data5.bin.......|
00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000060  00 00 00 00 30 30 30 30  36 34 34 00 30 30 30 30  |....0000644.0000|
00000070  30 30 30 00 30 30 30 30  30 30 30 00 30 30 30 30  |000.0000000.0000|
00000080  30 30 32 34 30 30 30 00  31 34 36 37 32 37 34 36  |0024000.14672746|
00000090  37 33 37 00 30 31 31 32  36 37 00 20 30 00 00 00  |737.011267. 0...|
000000a0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000100  00 75 73 74 61 72 20 20  00 72 6f 6f 74 00 00 00  |.ustar  .root...|
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$
```

It should be **64 61 74**, but I'm unable to find it in any resource!! After checking the hex representation again we see another magic number hidden:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output3.gz
00000000  64 61 74 61 35 2e 62 69  6e 00 00 00 00 00 00 00  |data5.bin.......|
00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
...
00000400  42 5a 68 39 31 41 59 26  53 59 d0 e6 93 b3 00 00  |BZh91AY&SY......|
00000410  8c 7f cf dc 6a 00 40 c0  7d ff e1 20 5b 23 80 75  |....j.@.}.. [#.u|
00000420  21 fe 80 00 08 40 00 00  66 82 01 88 08 4c 08 20  |!....@..f....L. |
00000430  00 94 0d 53 53 d3 44 68  62 1a 0d 06 8d 1a 0d 32  |...SS.Dhb......2|
00000440  1a 64 c9 a3 46 d4 c8 f5  06 92 1a 46 26 26 81 a3  |.d..F......F&&..|
00000450  4c 4c 8d 34 68 00 68 0c  23 43 73 dd 79 0f e4 08  |LL.4h.h.#Cs.y...|
00000460  0c 07 00 81 03 99 c7 14  0e 85 15 4c 5c 31 11 01  |...........L\1..|
00000470  f3 79 c1 cd de dc 76 23  35 0b 4c 58 78 cd bb c4  |.y....v#5.LXx...|
00000480  34 6d a6 08 5f 61 86 80  4a 36 40 44 49 ec 74 c4  |4m.._a..J6@DI.t.|
00000490  d0 4a bf 15 dc 26 28 5d  53 09 23 51 51 18 44 e2  |.J...&(]S.#QQ.D.|
000004a0  c9 62 35 45 95 6e cb ca  e3 c4 72 e0 e8 95 01 a1  |.b5E.n....r.....|
000004b0  f7 9a 3d 8a 44 00 e2 9e  ed dd f3 5a 81 31 5d 47  |..=.D......Z.1]G|
000004c0  07 8a a7 cf 27 2f 88 65  b2 57 42 27 42 0a f2 a9  |....'/.e.WB'B...|
000004d0  04 80 fe 2e e4 8a 70 a1  21 a1 cd 27 66 00 00 00  |......p.!..'f...|
000004e0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00005000
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$
```

Once again **42 5a 68** is the signature of .bz2 files, so I use ```xxd``` with the option -s to get only the lines starting from 0x400:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ xxd -s 0x400 output3.gz > output4.gz
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output4.gz | head
00000000  30 30 30 30 30 34 30 30  3a 20 34 32 35 61 20 36  |00000400: 425a 6|
00000010  38 33 39 20 33 31 34 31  20 35 39 32 36 20 35 33  |839 3141 5926 53|
00000020  35 39 20 64 30 65 36 20  39 33 62 33 20 30 30 30  |59 d0e6 93b3 000|
00000030  30 20 20 42 5a 68 39 31  41 59 26 53 59 2e 2e 2e  |0  BZh91AY&SY...|
00000040  2e 2e 2e 0a 30 30 30 30  30 34 31 30 3a 20 38 63  |....00000410: 8c|
00000050  37 66 20 63 66 64 63 20  36 61 30 30 20 34 30 63  |7f cfdc 6a00 40c|
00000060  30 20 37 64 66 66 20 65  31 32 30 20 35 62 32 33  |0 7dff e120 5b23|
00000070  20 38 30 37 35 20 20 2e  2e 2e 2e 6a 2e 40 2e 7d  | 8075  ....j.@.}|
00000080  2e 2e 20 5b 23 2e 75 0a  30 30 30 30 30 34 32 30  |.. [#.u.00000420|
00000090  3a 20 32 31 66 65 20 38  30 30 30 20 30 38 34 30  |: 21fe 8000 0840|
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ xxd -r output4.gz output4.bz2
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output4.bz2
00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000400  42 5a 68 39 31 41 59 26  53 59 d0 e6 93 b3 00 00  |BZh91AY&SY......|
00000410  8c 7f cf dc 6a 00 40 c0  7d ff e1 20 5b 23 80 75  |....j.@.}.. [#.u|
00000420  21 fe 80 00 08 40 00 00  66 82 01 88 08 4c 08 20  |!....@..f....L. |
00000430  00 94 0d 53 53 d3 44 68  62 1a 0d 06 8d 1a 0d 32  |...SS.Dhb......2|
00000440  1a 64 c9 a3 46 d4 c8 f5  06 92 1a 46 26 26 81 a3  |.d..F......F&&..|
00000450  4c 4c 8d 34 68 00 68 0c  23 43 73 dd 79 0f e4 08  |LL.4h.h.#Cs.y...|
00000460  0c 07 00 81 03 99 c7 14  0e 85 15 4c 5c 31 11 01  |...........L\1..|
00000470  f3 79 c1 cd de dc 76 23  35 0b 4c 58 78 cd bb c4  |.y....v#5.LXx...|
00000480  34 6d a6 08 5f 61 86 80  4a 36 40 44 49 ec 74 c4  |4m.._a..J6@DI.t.|
00000490  d0 4a bf 15 dc 26 28 5d  53 09 23 51 51 18 44 e2  |.J...&(]S.#QQ.D.|
000004a0  c9 62 35 45 95 6e cb ca  e3 c4 72 e0 e8 95 01 a1  |.b5E.n....r.....|
000004b0  f7 9a 3d 8a 44 00 e2 9e  ed dd f3 5a 81 31 5d 47  |..=.D......Z.1]G|
000004c0  07 8a a7 cf 27 2f 88 65  b2 57 42 27 42 0a f2 a9  |....'/.e.WB'B...|
000004d0  04 80 fe 2e e4 8a 70 a1  21 a1 cd 27 66 00 00 00  |......p.!..'f...|
000004e0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00005000
```

The file starts with garbage data before the signature so I just remove them first then decompress the new file:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ bzip2 -kd output4.bz2

bzip2: output_hex.bz2: trailing garbage after EOF ignored
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output4
00000000  64 61 74 61 38 2e 62 69  6e 00 00 00 00 00 00 00  |data8.bin.......|
00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000060  00 00 00 00 30 30 30 30  36 34 34 00 30 30 30 30  |....0000644.0000|
00000070  30 30 30 00 30 30 30 30  30 30 30 00 30 30 30 30  |000.0000000.0000|
00000080  30 30 30 30 31 31 37 00  31 34 36 37 32 37 34 36  |0000117.14672746|
00000090  37 33 37 00 30 31 31 32  37 35 00 20 30 00 00 00  |737.011275. 0...|
000000a0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000100  00 75 73 74 61 72 20 20  00 72 6f 6f 74 00 00 00  |.ustar  .root...|
00000110  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000120  00 00 00 00 00 00 00 00  00 72 6f 6f 74 00 00 00  |.........root...|
00000130  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000200  1f 8b 08 08 df cd eb 66  02 03 64 61 74 61 39 2e  |.......f..data9.|
00000210  62 69 6e 00 0b c9 48 55  28 48 2c 2e 2e cf 2f 4a  |bin...HU(H,.../J|
00000220  51 c8 2c 56 70 f3 37 4d  29 77 2b 4e 36 48 4e 4a  |Q.,Vp.7M)w+N6HNJ|
00000230  f4 cc f4 30 c8 b0 f0 32  4a 0d cd 2e 36 2a 4b 09  |...0...2J...6*K.|
00000240  71 29 77 cc e3 02 00 3e  de 32 41 31 00 00 00 00  |q)w....>.2A1....|
00000250  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00002800
```

The new file also shows the signature not starting from the beginning, instead from the offset 0x200 and we see the signature for .gz file so we repeat the same steps to get only the bytes starting from 0x200 into a new file and using ```xxd -r``` command we revert it:

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ xxd -s 0x200 output4 > output5.txt
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output5.txt | head
00000000  30 30 30 30 30 32 30 30  3a 20 31 66 38 62 20 30  |00000200: 1f8b 0|
00000010  38 30 38 20 64 66 63 64  20 65 62 36 36 20 30 32  |808 dfcd eb66 02|
00000020  30 33 20 36 34 36 31 20  37 34 36 31 20 33 39 32  |03 6461 7461 392|
00000030  65 20 20 2e 2e 2e 2e 2e  2e 2e 66 2e 2e 64 61 74  |e  .......f..dat|
00000040  61 39 2e 0a 30 30 30 30  30 32 31 30 3a 20 36 32  |a9..00000210: 62|
00000050  36 39 20 36 65 30 30 20  30 62 63 39 20 34 38 35  |69 6e00 0bc9 485|
00000060  35 20 32 38 34 38 20 32  63 32 65 20 32 65 63 66  |5 2848 2c2e 2ecf|
00000070  20 32 66 34 61 20 20 62  69 6e 2e 2e 2e 48 55 28  | 2f4a  bin...HU(|
00000080  48 2c 2e 2e 2e 2f 4a 0a  30 30 30 30 30 32 32 30  |H,.../J.00000220|
00000090  3a 20 35 31 63 38 20 32  63 35 36 20 37 30 66 33  |: 51c8 2c56 70f3|
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ xxd -r output5.txt output5.gz
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output5.gz
00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000200  1f 8b 08 08 df cd eb 66  02 03 64 61 74 61 39 2e  |.......f..data9.|
00000210  62 69 6e 00 0b c9 48 55  28 48 2c 2e 2e cf 2f 4a  |bin...HU(H,.../J|
00000220  51 c8 2c 56 70 f3 37 4d  29 77 2b 4e 36 48 4e 4a  |Q.,Vp.7M)w+N6HNJ|
00000230  f4 cc f4 30 c8 b0 f0 32  4a 0d cd 2e 36 2a 4b 09  |...0...2J...6*K.|
00000240  71 29 77 cc e3 02 00 3e  de 32 41 31 00 00 00 00  |q)w....>.2A1....|
00000250  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00002800
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ gzip -kd output5.gz

gzip: output3.gz: not in gzip format
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ ### The file begins with empty spaces so I just remove them then extracting the file is successful
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output5.gz
00000000  1f 8b 08 08 df cd eb 66  02 03 64 61 74 61 39 2e  |.......f..data9.|
00000010  62 69 6e 00 0b c9 48 55  28 48 2c 2e 2e cf 2f 4a  |bin...HU(H,.../J|
00000020  51 c8 2c 56 70 f3 37 4d  29 77 2b 4e 36 48 4e 4a  |Q.,Vp.7M)w+N6HNJ|
00000030  f4 cc f4 30 c8 b0 f0 32  4a 0d cd 2e 36 2a 4b 09  |...0...2J...6*K.|
00000040  71 29 77 cc e3 02 00 3e  de 32 41 31 00 00 00 00  |q)w....>.2A1....|
00000050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00002600
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ gzip -kd output5.gz
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$
```

**TADA!!!**

```
bandit12@bandit:/tmp/tmp.ydWoyX3Bw9$ hd output5
00000000  54 68 65 20 70 61 73 73  77 6f 72 64 20 69 73 20  |The password is |
```

Now we finally have the text file so we copy the password for bandit13 user and we can go to the next level.