//共通
eps = 0.01;
ball_r = 3*1.3/2;
lack_r = 0;
lack_normal = 0;

//inside
in_h = 7;
in_r = 10/2;
in_gap = 1;

//out
out_h = in_h;
out_r = 20/2;
out_gap =1;

//screw
outscrew_head_h = 0;
outscrew_head_r = 0;
outscrew_big_h = 0;
outscrew_big_r = 0;
outscrew_small_h = 0;
outscrew_small_r = 0;



//hold
hold_h = ball_r*2+3;
hold_in_r = in_r-in_gap+0.5;
hold_out_r = hold_in_r+in_gap+out_gap-0.5;

hold_ball_r = ball_r+1;
hold_ball_number = 4;

$fn = 80;


/*
show=
    [1,//outside
     2,//hold
     3,//inside
    ]
cut = 1,2;//1:実施,2:非実施

*/


show=[1,2,3];
cut = 1;//0:非実施,1:実施

if(search(1,show)!=[])
    inside();

if(search(2,show)!=[])
    hold();

cut_gap = 10;  // 移動量
if (search(3, show) != []) {
    if (cut == 0) {
        outside();
    } else {
        // z < 0 側
        intersection() {
            outside();

            translate([-100, -100, -100])
                cube([200, 200, 100]);
        }

        // z > 0 側を上に移動
        translate([0, 0, cut_gap])
        intersection() {
            outside();

            translate([-100, -100, 0])
                cube([200, 200, 100]);
        }
    }
}



module inside() {
    color("green")
    difference() {
        // 本体
        cylinder(
            h = in_h,
            r = in_r - in_gap,
            center = true
        );

        // ボール用の一周溝
        rotate_extrude(angle = 360)
        translate([in_r - in_gap, 0])
            circle(r = ball_r);
    }
}


module hold() {
    color("orange")
    difference() {
        cylinder(h = hold_h, r = hold_out_r, center = true);
        cylinder(h = hold_h+0.2, r = hold_in_r, center = true);
        for(i=[0:hold_ball_number-1]){
        rotate([0,90,360/hold_ball_number * i])
        cylinder(h = hold_out_r*2+0.2, r = hold_ball_r, center = true);
        }
    }
    
}

module outside() {
    color("yellow")
    difference() {
        // 本体
        cylinder(h = out_h,r = out_r,center = true);
        cylinder(h = out_h+0.2,r = in_r+out_gap,center = true);
        // ボール用の一周溝
        rotate_extrude(angle = 360)
        translate([in_r + out_gap, 0])
            circle(r = ball_r);
    }
    
}
