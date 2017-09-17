package com.example.androidthings.myproject;

import android.util.Log;

import java.io.IOException;

import com.google.android.things.contrib.driver.mma8451q.Mma8451Q;
import com.google.android.things.pio.Gpio;

import static java.util.Locale.US;

/**
 * HW3 Movement
 * Based on HW3 Template by bjoern on 9/12/17.
 * Wiring:
 * USB-Serial Cable:
 *   GND to GND on IDD Hat
 *   Orange (Tx) to UART6 RXD on IDD Hat
 *   Yellow (Rx) to UART6 TXD on IDD Hat
 * Accelerometer:
 *   Vin to 3V3 on IDD Hat
 *   GND to GND on IDD Hat
 *   SCL to SCL on IDD Hat
 *   SDA to SDA on IDD Hat
 */

public class MovementApp extends SimplePicoPro {

    Mma8451Q accelerometer;

    Gpio fireButton = GPIO_128;
    Gpio reloadButton = GPIO_39;


    float[] xyz = {0.f,0.f,0.f}; //store X,Y,Z acceleration of MMA8451 accelerometer here [units: G]

    public void setup() {
        // Initialize the serial port for communicating to a PC
        uartInit(UART6,9600);

        // Initialize the MMQ8451 Accelerometer
        try {
            accelerometer = new Mma8451Q("I2C1");
            accelerometer.setMode(Mma8451Q.MODE_ACTIVE);
        } catch (IOException e) {
            Log.e("Movement","setup",e);
        }

        // set edge triggers for fire and reload buttons
        setEdgeTrigger(fireButton, Gpio.EDGE_FALLING);
        setEdgeTrigger(reloadButton, Gpio.EDGE_FALLING);
    }

    public void loop() {
        // read I2C accelerometer and print to UART
        try {
            xyz = accelerometer.readSample();

            println(UART6,xyz[0]+","+xyz[1]+","+xyz[2]);
            println(String.format(US, "%10.5f \t %10.5f \t %10.5f", xyz[0], xyz[1], xyz[2]));

            //println("X: "+xyz[0]+"   Y: "+xyz[1]+"   Z: "+xyz[2]);

            //use this line instead for unlabeled numbers separated by tabs that work with Arduino's SerialPlotter:
            //println(UART6,xyz[0]+"\t"+xyz[1]+"\t"+xyz[2]); // this goes to the Serial port

        } catch (IOException e) {
            Log.e("Movement","loop",e);
        }

        delay(50);
    }

    @Override
    void digitalEdgeEvent(Gpio pin, boolean value) {
        // when button is pressed down for pull up resistor switches
        // Fire event
        if(pin==fireButton && value==LOW) {
            println(UART6, "1");
            delay(25);
            println(UART6, "3");
            println("fire");
        }

        // when button is pressed down for pull up resistor switches
        // reload event
        else if (pin==reloadButton && value==LOW) {
            println(UART6, "2");
            delay(25);
            println(UART6, "3");
            println("reload");
        }
    }
}
