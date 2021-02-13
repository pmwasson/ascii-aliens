;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Paths
;
; Paths are all relative.
; 

; Segment (4-bytes)
;   x_speed         d,0.xxxxxxx     s:0=right,1=left
;   y_speed         d,0.yyyyyyy     s:0=up,1=down
;   count           0 = end (explode?), 1-255 duration count
;   next            nnnnnn00 

.align 256

path:

path_0:
    ; Use a spread sheet to figure out paths
    ;       x       y       count   next    x1,y1 -> x2,y2  speed   dx  dy  distance
    .byte   26  ,   0   ,   150 ,   4   ;   2   2   32  2   0.2     30  0   30.00
    .byte   0   ,   25  ,   50  ,   8   ;   32  2   32  12  0.2     0   10  10.00
    .byte   154 ,   0   ,   150 ,   12  ;   32  12  2   12  0.2     -30 0   30.00
    .byte   0   ,   153 ,   50  ,   16  ;   2   12  2   2   0.2     0   -10 10.00
    .byte   27  ,   43  ,   53  ,   20  ;   2   2   13  20  0.4     11  18  21.10
    .byte   37  ,   162 ,   66  ,   24  ;   13  20  32  2   0.4     19  -18 26.17
    .byte   180 ,   0   ,   75  ,   0   ;   32  2   2   2   0.4     -30 0   30.00