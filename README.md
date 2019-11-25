# AZERTY

When Apple launched the IIgs in France it obviously came with a French (AZERTY) keyboard. However, while that keyboard worked fine with legacy Apple II applications it was a disaster for modern GS/OS applications. The main problems were related to incorrect key mappings for several usual characters and no support for accented characters.

In order to be able to enter accented characters, users had to memorize complex unintuitive keyboard combinations. Since I used my computer not just for programming but also to produce documents, I decided this had to be fixed. The AZERTY New Desk Accessory (NDA) is quite simple, it hijacks the keyboard interrupt handler and examines what the user is typing. If an accent is typed, the key down event is ignored until the next character (presumably a vowel) is entered, at which time both characters are combined. If both characters cannot be combined, the NDA simply handles the key presses as independent events.

[[https://github.com/huibert7/AZERTY/blob/master/Documentation/Screenshots/Info.jpg|alt=NDA Information]]

Take a look at the documentation on the project's [wiki](https://github.com/huibert7/G.A.P.E.-Global-Applesoft-Program-Editor-/wiki)
