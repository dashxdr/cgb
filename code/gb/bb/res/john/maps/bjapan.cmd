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

-Inform			Converting GMB Big Board

-BrighterColors Yes

			bguard.bbm

			bjapans1.pcx
			bjapans2.pcx
			bjapans3.pcx
			bjapanm1.pcx
			bjapanm2.pcx
			bjapanm3.pcx
			bjapanm4.pcx

-ClearMaps

