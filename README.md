# IEEE 855 (MOSI) Interface for CP-M 80 and Pascal MT+

This was written by James D. Mooney (West Viriginia University), and published
as SIG/M Volume 253 in 1986.

All I have done is extract the archive and upload it to GitHub.

I got the archive from the [Walnut Creek CPM CD-ROM (November 1994)](https://archive.org/details/cdrom-1994-11-walnutcreek-cpm).
It is the file `CPM_CDROM/SIMTEL/SIGM/VOLS200/VOL253/MOSI.LBR`.

That is a CP/M LBR/LU format archive, which I extracted using [`lar`](https://github.com/skissane/lar).
The files within the archive are compressed using [SQUEEZE](https://github.com/skissane/squeeze).

```
SIG/M    Volume 253     IEEE 855 (MOSI) Interface for CP-M 80
                        and Language Interface for Pascal MT+
                        by James D. Mooney

                        released    January 17, 1986
```

Note the files `ABSTRACT.253` and `0CATALOG.253` do not come from that archive, they come from the `CPM_CDROM/SIMTEL/SIGM/VOLS200/VOL253` directory.

# License

Original license (extracted from `ABSTRACT.253`, also placed in `LICENSE` file):
```
   Some of the source files on this disk are Copyright 1985 by
James D. Mooney.  Permission is hereby granted to use, reproduce, and
modify these files for any purpose whatsoever, provided that the
Copyright notice is retained.

                                                Jim Mooney
                                                September, 1985
```

# Documentation files

* [MOSICPM.DOC](./MOSICPM.DOC): manual for this library
* [CPMSPEC.DOC](./CPMSPEC.DOC): conformance document describing limitations/interpretations of this implementation of MOSI standard
* [MODREL.DOC](./MODREL.DOC): manual for `MODREL` utility to work-around the 6 character symbol name limit of the Digital Research RMAC assembler
