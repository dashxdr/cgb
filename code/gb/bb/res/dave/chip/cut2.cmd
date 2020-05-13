; XS command script for creating ...
;

-Machine		Gameboy

-FilterChrs		No
-WriteProcessed		No

-RemapInput		No
-FilterInput		No
-ZeroTransparent	Yes

-ZeroColourZero		Yes

-PaletteAlphaRGB	No

-ReferenceFrame		Yes
;-FindEdges		Yes
;-SprOnlyLRTB		No
-SprOnlyLRTB		Yes
-FindEdges		No

-MapType		Spr
-RemoveCHRRepeats	Yes
-RemoveBLKRepeats	Yes
-RemoveMAPRepeats	Yes
-RemoveSPRRepeats	No

-ChrWidth		8
-ChrHeight		8
-ChrBitsPerPixel	2
-AllowChrXFlip		No
-AllowChrYFlip		No
-StoreChrPriority	No
-StoreChrFlip		No
-StoreChrPalette	No

-ChrMapOrder		LRTB
-ChrMapOffset		0
-ChrMapToBlkMap		No
;-AllowMapXFlip		No
;-AllowMapYFlip		No
-StoreMapPosition	Yes
-StoreMapPalette	No

-SprBitsPerPixel	8
-SprCoding		Palette
-SprCompression		Unpacked
-SprDirection		TopToBottom

-OutputMapIndex		Yes
-OutputMapStart		0
-OutputMapPosition	Yes
-OutputMapBoxSize	No
-OutputWordOffsets	No
-OutputByteMap		No

-WriteCHR		Yes
-WriteBLK		No
-WriteMAP		Yes
-WriteRGB		No
-WriteSPR		No
-WriteIDX		No
-WriteRGB		Yes

-WriteRES		No

;
;
;
-BrighterColors YES

-Inform			Converting picture

