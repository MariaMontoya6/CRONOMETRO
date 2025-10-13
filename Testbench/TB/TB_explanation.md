# EXPLANATION

It is known that the testbench is intended to automatically stimulate the inputs and ensure compliance with the design requirements. Therefore, the focus will be on verifying that the design performs according to the intended specifications.

The VCD file generated for the GTKWave simulation exceeds GitHub’s size limit; for that reason, it is not included in the repository. However, you can easily generate it yourself by following the tutorials, as they include the testbench instructions.

## Anti debounce

The design was intended so that, after 16 clock cycles of the main 50 MHz signal, the input from any button would be recognized as valid on the next clock edge. This behavior is illustrated below.

<img src="../../Documentation/IMAGES/ANTIDEBOUNCE_START.png" alt="DE0-CV" width="1000">

*Antidebounce for start*

<img src="../../Documentation/IMAGES/ANTIDEBOUNCE_RESET.png" alt="DE0-CV" width="1000">

*Antidebounce for restart*

## Buttons working

The reset must stop the entire program; that’s why it has the highest priority. The start/pause button should function as both — starting or stopping the counting process.

<img src="../../Documentation/IMAGES/RESET_CHANGES.png" alt="DE0-CV" width="1000">

*Changes made for the reset*

<img src="../../Documentation/IMAGES/RUNNING_STATE_01.png" alt="DE0-CV" width="1000">

*Changes made for pause*

<img src="../../Documentation/IMAGES/UNPAUSE.png" alt="DE0-CV" width="1000">

*Changes made for unpause*

## Tick for 10ms

To allow the stopwatch to run, a tick signal was defined to trigger every 10 ms. It can be seen here.

<img src="../../Documentation/IMAGES/TICK_10ms.png" alt="DE0-CV" width="1000">

*The Tick of 10 mS*

## Chronometer logic

In the following section, different operating scenarios of the stopwatch can be observed.

<img src="../../Documentation/IMAGES/CHANGE_RUNNING_STATE.png" alt="DE0-CV" width="1000">

*Change of the running_state*

<img src="../../Documentation/IMAGES/CHANGE_HUNDREDTHS.png" alt="DE0-CV" width="1000">

*Change in the hundredths*

<img src="../../Documentation/IMAGES/CHANGE_OUTPUT.png" alt="DE0-CV" width="1000">

*Changes in the first seven segment display*

<img src="../../Documentation/IMAGES/60mS.png" alt="DE0-CV" width="1000">

*Chronometer working during 60 mS*