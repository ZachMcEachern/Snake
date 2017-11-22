;Zachary McEachern
;This file runs the full game of Snake

define snakeLength $00
define snakeHeadL $10
define snakeHeadH $11
define snakeBodyStartL $12
define snakeBodyStartH $13
define snakeTailL $14
define snakeTailH $15

define lastKeyPressed $ff
define snakeDir $01
define ASCII_w $77
define ASCII_a $61
define ASCII_s $73
define ASCII_d $64
define UP $01
define RIGHT $02
define DOWN $03
define LEFT $04

define appleLoPos $02
define appleHiPos $03
define randomByte $FE


init:
  ;Load up the snake pieces.
  LDA #$04
  STA snakeLength
  LDA #$40
  STA snakeHeadL
  LDA #$02
  STA snakeHeadH
  LDA #$20
  STA snakeBodyStartL
  LDA #$02
  STA snakeBodyStartH
  LDA #$00
  STA snakeTailL
  LDA #$02
  STA snakeTailH
  
  ;Start of the game board.
  LDA #$01
  LDX #$00
  STA snakeHeadL, x
  STA snakeBodyStartL, x
  LDA #DOWN
  STA snakeDir
  
  ;Initializing the Apple
  JSR setApplePos
  JSR drawApple
  
;Main Game Loop
loop: 
  JSR readKeys
  JSR checkAppleCollision
  JSR updateSnake
  JSR checkSnakeCollision
  JSR drawSnake
  JSR drawApple
  JSR slowDown
  JMP loop  

  ;Read in keys from the user.
readKeys:
  LDA lastKeyPressed
  CMP #ASCII_w
  BEQ upDir
  CMP #ASCII_d
  BEQ rightDir
  CMP #ASCII_s
  BEQ downDir
  CMP #ASCII_a
  BEQ leftDir
  RTS
  
checkAppleCollision: 
  ;With apple
  LDA snakeHeadL
  CMP appleLoPos            ;If the lo bites match, then check the high bites.
  BEQ checkCollisionAppleHi
  RTS
  
checkCollisionAppleHi:
  LDA snakeHeadH
  CMP appleHiPos
  BEQ collisionWithApple
  RTS
  
collisionWithApple:
  LDA #$01
  LDX #$00
  STA (appleLoPos, x)    ;Cover up the apple with a white pixel when eaten.
  LDA snakeLength
  CLC
  ADC #$02
  STA snakeLength
  ;brk
  JSR setApplePos
  RTS
  
  
upDir:
  LDA snakeDir
  CMP #DOWN
  BEQ earlyReturn
  LDA #UP
  STA snakeDir
  RTS
  
rightDir:
  LDA snakeDir
  CMP #LEFT
  BEQ earlyReturn
  LDA #RIGHT
  STA snakeDir
  RTS
  
downDir:
  LDA snakeDir
  CMP #UP
  BEQ earlyReturn
  LDA #DOWN
  STA snakeDir
  RTS
  
leftDir:
  LDA snakeDir
  CMP #RIGHT
  BEQ earlyReturn
  LDA #LEFT
  STA snakeDir
  RTS
  
updateSnake:
;Shift values, PART 1
  LDX snakeLength
  DEX
  updateLoop:
    ;brk
    LDA snakeHeadL, x
    STA snakeBodyStartL, x
    DEX
    BPL updateLoop
  ;update the head, PART 2  
  LDA snakeDir
  CMP #UP
  BEQ updateUpSnake
  CMP #RIGHT
  BEQ updateRightSnake
  CMP #DOWN
  BEQ updateDownSnake
  CMP #LEFT
  BEQ updateLeftSnake
  RTS 
  
checkSnakeCollision:
  LDX #$00
  LDA (snakeHeadL,x)
  CMP #$01                 ;If there is a white pixel already there, then end the game.
  BEQ endGame
  RTS

updateUpSnake:  
  SEC 
  LDA snakeHeadL
  SBC #$20
  STA snakeHeadL 
  BCC updateHiPosSubtract
  RTS
  
updateRightSnake:  
  CLC
  LDA snakeHeadL
  ADC #$01
  STA snakeHeadL
  LDA snakeHeadL
  AND #$1f
  BEQ endGame
  RTS
 
updateDownSnake:
  CLC
  LDA snakeHeadL
  ADC #$20
  STA snakeHeadL
  BCS updateHiPos      ;If it did carry then update the hiByte so we can get to the next quadrant.
  RTS
  
updateLeftSnake:
  SEC 
  LDA snakeHeadL
  SBC #$01
  STA snakeHeadL
  LDA snakeHeadL
  AND #$1f
  CMP #$1f
  BEQ endGame   
  RTS
  
drawSnake:
;Drawing the black tail pixel
  LDA #$00
  LDX snakeLength
  STA (snakeHeadL, x)
  
;Drawing the white head pixel
  LDA #$01
  LDX #$00
  STA (snakeHeadL, x)
  RTS
  
;Draws the apple in a random location flashing different colors.
drawApple:
  LDA randomByte
  AND #$0D
  CLC
  ADC #$02
  LDX #$00
  STA (appleLoPos, x)
  RTS
 
;Sets the apple a random position. 
setApplePos:
  LDA randomByte
  AND #$03
  CLC
  ADC #$02
  STA appleHiPos
  LDA randomByte
  STA appleLoPos
  RTS
  
slowDown:
  LDX #$0
  slowLoop:
    NOP
    DEX
    BNE slowLoop
    RTS
  
updateHiPos:
  INC snakeHeadH
  LDA #$06
  CMP snakeHeadH      ;Making sure that we don't go past the edge of the box.
  BEQ endGame
  ;BNE drawSnake     ;If we are still in the box then go back to updating the loByte.
  RTS
  
updateHiPosSubtract:
  DEC snakeHeadH
  LDA #$01
  CMP snakeHeadH      ;Making sure that we dont go past the top of the screen.
  BEQ endGame
  ;BNE drawSnake     ;If we are still on the screen then go back to drawing the snake.
  RTS
  
earlyReturn:
  RTS
 
;Ends the game and creates a pixel skull and bones. 
endGame:
  LDA #$01
  
  ;LDA #$02
  STA $028a
  STA $0295
  
  STA $02a9
  STA $02aa
  STA $02ac
  STA $02ad
  STA $02ae
  STA $02af
  STA $02b0
  STA $02b1
  STA $02b2
  STA $02b3
  STA $02b5
  STA $02b6
  
  ;LDA #$02
  STA $02cb
  STA $02cc
  STA $02cd
  STA $02ce
  STA $02cf
  STA $02d0
  STA $02d1
  STA $02d2
  STA $02d3
  STA $02d4
  
  ;LDA #$02
  STA $02ea
  STA $02eb
  STA $02ec
  STA $02ed
  STA $02ee
  STA $02ef
  STA $02f0
  STA $02f1
  STA $02f2
  STA $02f3
  STA $02f4
  STA $02f5
  
  ;LDA #$02
  STA $030a
  STA $030b
  STA $030c
  ;STA $030d
  STA $030e
  STA $030f
  STA $0310
  STA $0311
  ;STA $0312
  STA $0313
  STA $0314
  STA $0315
  
  ;LDA #$02
  STA $032a
  STA $032b
  ;STA $032c
  ;STA $032d
  ;STA $032e
  STA $032f
  STA $0330
  ;STA $0331
  ;STA $0332
  ;STA $0333
  STA $0334
  STA $0335
  
  ;LDA #$02
  STA $034a
  STA $034b
  ;STA $034c
  ;STA $034d
  STA $034e
  STA $034f
  STA $0350
  STA $0351
  ;STA $0352
  ;STA $0353
  STA $0354
  STA $0355
  
  ;LDA #$02
  ;STA $036a
  STA $036b
  STA $036c
  STA $036d
  STA $036e
  ;STA $036f
  ;STA $0370
  STA $0371
  STA $0372
  STA $0373
  STA $0374
  ;STA $0375
  
  ;LDA #$02
  STA $0389
  STA $038a
  ;STA $038b
  ;STA $038c
  STA $038d
  STA $038e
  STA $038f
  STA $0390
  STA $0391
  STA $0392
  ;STA $0393
  ;STA $0394
  STA $0395
  STA $0396
  
  ;LDA #$01
  ;STA $03a9
  STA $03aa
  ;STA $03ab
  ;STA $03ac
  STA $03ad
  ;STA $03ae
  STA $03af
  STA $03b0
  ;STA $03b1
  STA $03b2
  ;STA $03b3
  ;STA $03b4
  STA $03b5
  ;STA $03b6
  
  BRK