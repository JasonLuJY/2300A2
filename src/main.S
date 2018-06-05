  .syntax unified
  .global main
  .type main, %function

main:
  @ r4 frequency
  @ r5 duration
  bl init
  b begin

  @ function for making a sawtooth sound wave
  make_sound:
    @ store the value of lr because there
    @ is a nested function
    push {lr}
    mov r6, 0x10000
    mul r4, r6
    mov r7, 48000
    udiv r4, r7
    mov r8, 0
    mov r9, 0
    
    inner_loop:
      @ r8 stores the value for r0 to make sound.
      @ r4 stores the value that the value that 
      @ every time r8 should be added up with.
      @ r9 represents the number of times that BSP
      @ is called, so that the sound can be stopped
      @ in given duration
      add r8, r4
      mov r0, r8
      bl BSP_AUDIO_OUT_Play_Sample
      add r9, 1
      cmp r9, r5
      bne inner_loop

    pop {lr}
    bx lr


  begin:
  @ r4 represents frequency
  @ and r5 represents duration (one second per 4.8k)
  mov r4, 440
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 24000
  bl make_sound
  mov r4, 524
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 24000
  bl make_sound
  mov r4, 440
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 12000
  bl make_sound
  mov r4, 440
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 24000
  bl make_sound
  mov r4, 524
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 24000
  bl make_sound
  mov r4, 440
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 12000
  bl make_sound
  mov r4, 440
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 24000
  bl make_sound
  mov r4, 524
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 24000
  bl make_sound
  mov r4, 440
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 12000
  bl make_sound
  mov r4, 494
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 24000
  bl make_sound
  mov r4, 440
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 24000
  bl make_sound
  mov r4, 392
  mov r5, 12000
  bl make_sound
  mov r4, 0
  mov r5, 12000
  bl make_sound

  b begin
  b main
  .size main, .-main
