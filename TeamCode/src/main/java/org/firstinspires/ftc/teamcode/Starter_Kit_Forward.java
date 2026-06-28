//This program is made by Yuta Kimura (Hibana)
package org.firstinspires.ftc.teamcode;

import com.qualcomm.robotcore.eventloop.opmode.LinearOpMode;
import com.qualcomm.robotcore.eventloop.opmode.TeleOp;
import com.qualcomm.robotcore.hardware.DcMotor;
import com.qualcomm.robotcore.hardware.DcMotorSimple;

@TeleOp(name = "Starter-Kit_Forward", group = "Kimura")
public class Starter_Kit_Forward extends LinearOpMode {

    private static final String LEFT_MOTOR = "leftMotor";
    private static final String RIGHT_MOTOR = "rightMotor";

    @Override
    public void runOpMode() {
        DcMotor leftmotor = hardwareMap.get(DcMotor.class, LEFT_MOTOR);
        DcMotor rightmotor = hardwareMap.get(DcMotor.class, RIGHT_MOTOR);

        leftmotor.setDirection(DcMotorSimple.Direction.FORWARD);
        rightmotor.setDirection(DcMotorSimple.Direction.FORWARD);

        leftmotor.setMode(DcMotor.RunMode.RUN_WITHOUT_ENCODER);
        rightmotor.setMode(DcMotor.RunMode.RUN_WITHOUT_ENCODER);

        leftmotor.setZeroPowerBehavior(DcMotor.ZeroPowerBehavior.BRAKE);
        rightmotor.setZeroPowerBehavior(DcMotor.ZeroPowerBehavior.BRAKE);

        telemetry.addData("Status", "Initialized");
        telemetry.addData("leftMotor", LEFT_MOTOR);
        telemetry.addData("rightMotor", RIGHT_MOTOR);
        telemetry.update();

        waitForStart();

        while (opModeIsActive()) {
            double power = gamepad1.right_trigger;

            leftmotor.setPower(power);
            rightmotor.setPower(power);

            telemetry.addData("Status", "Running");
            telemetry.addData("Motor Power", "%.2f", power);
            telemetry.addData("Trigger (RT)", "%.2f", gamepad1.right_trigger);
            telemetry.update();
        }

        leftmotor.setPower(0);
        rightmotor.setPower(0);
    }
}
