  .syntax unified
  .global main
  .type main, %function

main:

  @ r4 frequency
  @ r5 amplitude
  @ r6 duration

  b begin

  @ By changing the value of amplitude,
  @ this function realise an ampiltude
  @ envelop as an arbitary ADSR
  amplitude:
    ldr r7, =0x20000010
    ldr r5, [r7]
    mov r7, 0x20000000
    ldr r11, [r7]
    sub r11, r6
    ldr r7, =1200
    cmp r11, r7
    bpl case_1

    @ case_0: attack phase
    mul r5, r11
    udiv r5, r7
    mov r7, r5
    b end_case

    @ case_1: decay phase
    case_1:
    ldr r7, =1800
    cmp r11, r7
    bpl case_2
    add r11, 600
    sub r11, r7
    mul r11, r5
    sub r7, 300
    udiv r11, r7
    sub r5, r7
    mov r7, r5
    b end_case

    @ case_2: sustain phase
    case_2:
    ldr r7, =3000
    cmp r6, r7
    bpl case_3
    mov r7, r6
    mul r7, r5
    ldr r5, =5000
    udiv r7, r5
    b end_case

    @ case_3: release phase
    case_3:
    mov r7, 3
    mul r7, r5
    mov r5, 5
    udiv r7, r5
    end_case:

    mov r5, r7
    bx lr


  @ sinx function reuse my code in 
  @ assignment 1, and can calculate 
  @ the value of sine function

  sinx:

      @ r11 equals to 24000/(pi*frequency*counter), just for convenience
      ldr r11, =7639
      udiv r11, r4

      @ sinx = x - x^3/3! + x^5/5! - ... 
      @ this is the first piece of the polynomial
      mov r9, r5
      mul r9, r10
      udiv r9, r11
      mov r8, r9  

      @ second piece of the polynomial
      mov r9, r10
      mul r9, r10
      mul r9, r10
      udiv r9, r11
      mul r9, r5
      udiv r9, r11
      udiv r9, r11
      mov r7, 6
      udiv r9, r7
      sub r8, r9

      @ third piece of the polynomial
      mov r9, r10
      mul r9, r10
      udiv r9, r11
      mul r9, r10
      udiv r9, r11
      mul r9, r10
      udiv r9, r11
      mul r9, r10
      udiv r9, r11
      mul r9, r5
      udiv r9, r11
      mov r7, 120
      udiv r9, r7
      add r8, r9

      bx lr


  @ function for making sound,
  @ reuse my code in Assignment 1
  sine:
    mov r7, 0x20000000
    str r6, [r7]
    ldr r7, =0x20000010
    str r5, [r7]
    sound_loop:
    mov r12, 12000
    udiv r12, r4
    mov r10, 0
    @ change the amplitude after a cycle
    bl amplitude

    zero:
      bl sinx
      mov r0, r8
      bl BSP_AUDIO_OUT_Play_Sample
      sub r6, 1
      add r10, 1
      cmp r10, r12
      bne zero 
    mov r10, r12

    half_pi:
      bl sinx
      mov r0, r8
      bl BSP_AUDIO_OUT_Play_Sample
      sub r6, 1
      subs r10, 1
      bne half_pi
      
    mov r10, 0
    one_pi:
      bl sinx
      mov r0, 0
      sub r0, r8
      bl BSP_AUDIO_OUT_Play_Sample
      sub r6, 1
      add r10, 1
      cmp r10, r12
      bne one_pi

    mov r10, r12

    one_and_half_pi:
      bl sinx
      mov r0, 0
      sub r0, r8
      bl BSP_AUDIO_OUT_Play_Sample
      sub r6, 1
      subs r10, 1
      bne one_and_half_pi
    cmp r6, 0
    bpl sound_loop
    pop {lr}
  bx lr

@ keep silence
silence:
  push {lr}
  inner:
  bl BSP_AUDIO_OUT_Play_Sample
  subs r6, 1
  bne inner
  pop {lr}
  bx lr

@ play sawtooth sound wave
sawtooth:
  inner_2:   
  
  @ change the amplitude after a cycle
  bl amplitude
  mov r7, 0
  sub r7, r5
  mov r8, r5
  mul r8, r4
  ldr r9, =24000
  udiv r8, r9
  inner_3:
    add r7, r8
    mov r0, r7
    bl BSP_AUDIO_OUT_Play_Sample
    sub r6, 1
    cmp r7, r5
    bmi inner_3
  cmp r6, 0
  bpl inner_2
  pop {lr}
  bx lr

@ play square sound wave
square:
  bl amplitude
  ldr r7, =12000
  udiv r7, r4
  loop_1:
    mov r0, r5
    bl BSP_AUDIO_OUT_Play_Sample
    sub r6, 1
    subs r7, 1
    bne loop_1

  ldr r7, =12000
  udiv r7, r4
  loop_2:
    mov r0, 0
    sub r0, r5
    bl BSP_AUDIO_OUT_Play_Sample
    sub r6, 1
    subs r7, 1
    bne loop_2
  cmp r6, 0
  bpl square
  pop {lr}
  bx lr

  @ choose the wave
  make_sound:
    push {lr}
    @b square
    b sine
    @b sawtooth

  begin:

  bl init
  @ set amplitude(0 to 0x7fff)
  mov r5, 0x4000
  
  @ main loop, simiar to part_1
  @ simply plays the sound for
  @ the first part of Shape of You
  @ r4 is for frequency
  @ r5 is for duration 4.8k/s
  loop:
  mov r4, 440
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 24000
  bl silence
  ldr r4, =523
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 24000
  bl silence
  mov r4, 440
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 12000
  bl silence
  mov r4, 440
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 24000
  bl silence
  mov r4, 524
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 24000
  bl silence
  mov r4, 440
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 12000
  bl silence
  mov r4, 440
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 24000
  bl silence
  mov r4, 524
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 24000
  bl silence
  mov r4, 440
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 12000
  bl silence
  mov r4, 494
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 24000
  bl silence
  mov r4, 440
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 24000
  bl silence
  mov r4, 392
  mov r6, 12000
  bl make_sound
  mov r4, 0
  mov r6, 12000
  bl silence
  b loop
  b main
  .size main, .-main