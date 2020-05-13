; XS command script for creating a Gameboy CGB bitmap ...
;

-Machine		Gameboy

-FilterChrs		Yes
-WriteProcessed		No

-RemapInput		No
-FilterInput		No
-ZeroTransparent	No
-UseNewPalette		No

-ZeroColourZero		No

-PaletteAlphaRGB	No

-ReferenceFrame		No
-FindEdges		No

-MapType		Chr
-RemoveCHRRepeats	Yes
-RemoveBLKRepeats	Yes
-RemoveMAPRepeats	No
-RemoveSPRRepeats	No

-ChrWidth		8
-ChrHeight		8
-ChrBitsPerPixel	2
-AllowChrXFlip		No
-AllowChrYFlip		No
-StoreChrNumber		Yes
-StoreChrPriority	No
-StoreChrFlip		No
-StoreChrPalette	Yes

-BlkWidth		3
-BlkHeight		3

-ChrMapOrder		LRTB
-ChrMapOffset		0
-ChrMapToBlkMap		Yes
;-AllowMapXFlip		No
;-AllowMapYFlip		No
-StoreMapPosition	No
-StoreMapPalette	No

-SprBitsPerPixel	8
-SprCoding		Palette
-SprCompression		Unpacked
-SprDirection		TopToBottom

-OutputMapIndex		No
-OutputMapStart		0
-OutputMapPosition	No
-OutputMapBoxSize	No
-OutputWordOffsets	No
-OutputByteMap		No

-WriteCHR		No
-WriteBLK		No
-WriteMAP		Yes

-WriteRGB		No
-WriteSPR		No
-WriteIDX		No

-WriteRES		No

;
;
;

-Inform			Converting CGB Big Board
-BrighterColors Yes

			cguard.bbm

			cjapans1.pcx
			cjapans2.pcx
			cjapans3.pcx
			cjapanm1.pcx
			cjapanm2.pcx
			cjapanm3.pcx
			cjapanm4.pcx

-ClearMaps

