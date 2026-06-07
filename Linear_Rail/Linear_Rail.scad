include <BOSL2/std.scad>
$fn = 20;
circlefn =30;
//共通
Space_Upper_Wide = 17;
Space_Under_Wide = 13;

Space_Upper_High = 5;
Space_Under_High = 4;

Ball_radius = 3.5/2; //直径2.5mmを採用
Groove = 1;

//レール
Rail_Thickness = 150;
Rail_High = 15;
Rail_Wide = 30;

Rail_Space_Upper_Wide = Space_Upper_Wide+Groove;
Rail_Space_Under_Wide = Space_Under_Wide+Groove;

Rail_Space_Upper_High = Space_Upper_High;
Rail_Space_Under_High = Space_Under_High+Groove;

Rail_Nail_Wide = 2;
Rail_Nail_High = 1.5;

//ブロック
Block_Thickness = 20;

Block_Space_Upper_Wide = Space_Upper_Wide-Groove;
Block_Space_Under_Wide = Space_Under_Wide-Groove;

Block_Space_Upper_High = Space_Upper_High;
Block_Space_Under_High = Space_Under_High-Groove/2;

Block_Tube_Radius = Ball_radius*1.3;
Block_Tube_Distance = 5;
//ブロックエンド
Blockend_Thickness = 10;
Blockend_Radius = Ball_radius*0.8;

//ブロックエンド
Blockend_Rail_Nail_Wide = Rail_Nail_Wide*0.7;
//ブロックエンド
Blockend_Rail_Nail_High = Rail_Nail_High*0.7;

/*viewmode
0:全部表示
1:レールだけ
2:ブロックだけ
*/
viewmode = 1;

/* ブロックsplitmode
0:結合
1:分割表示
*/
splitmode = 1;

if (viewmode==0||viewmode==1){
    color("yellow")
    rail();
}

if (viewmode == 0 || viewmode == 2) {

    color("green")

    if (splitmode == 0) {
        // 通常表示
        blockandscrew();
    }

    if (splitmode == 1) {

        cut_y = Rail_High/2
              - Block_Space_Upper_High
              + Blockend_Rail_Nail_High/2;

        // 上半分
        intersection() {
            union() {
                blockandscrew();
            }

            translate([-1000, cut_y, -1000])
                cube([2000, 1000, 2000]);
        }

        // 下半分
        translate([40, 0, 0]) {
            intersection() {
                union() {
                    blockandscrew();
                }

                translate([-1000, -1000, -1000])
                    cube([2000, cut_y + 1000, 2000]);
            }
        }
    }
}





//ブロック----------------------------------------------
module blockandscrew(){
    difference(){
        block();
        translate([0,Rail_High/2,-7])
        rotate([90,0,0])
        screw();
        translate([0,Rail_High/2,27])
        rotate([90,0,0])
        screw();
    }
    
}






module block(){
    linear_extrude(height = Block_Thickness)
    difference(){//本体
         translate([0,Rail_High/2-Block_Space_Upper_High])//本体
         polygon(points=[
            [-Block_Space_Upper_Wide/2,Block_Space_Upper_High],
            [-Block_Space_Upper_Wide/2,0], 
            [-Block_Space_Under_Wide/2,-Block_Space_Under_High],
            [Block_Space_Under_Wide/2,-Block_Space_Under_High],
            [Block_Space_Upper_Wide/2,0], 
            [Block_Space_Upper_Wide/2,Block_Space_Upper_High],

        ]);         
        for (x=[-1,1]) {//ボール用溝
            translate([
                x * Space_Upper_Wide/2,
                Rail_High/2-Block_Space_Upper_High
            ])
            circle(r = Ball_radius, $fn = circlefn);
        } 
        for (x=[-1,1]) {//ボール用溝
            translate([
                x * Block_Tube_Distance/2,
                Rail_High/2-Block_Space_Upper_High
            ])
            circle(r = Block_Tube_Radius, $fn = circlefn);
        }
        

        
        
    }
    translate([0,Rail_High/2-Rail_Space_Upper_High,Block_Thickness])
    blockend();
    rotate([0,180,0])
    translate([0,Rail_High/2-Rail_Space_Upper_High,0])
    blockend();
   
}

//ブロック端
module blockend(){
    difference(){
        linear_extrude(height=Blockend_Thickness)
        union(){
            polygon(points=[
                [-Block_Space_Upper_Wide/2,Block_Space_Upper_High],
                [-Block_Space_Upper_Wide/2,0], 
                [-Block_Space_Under_Wide/2,-Block_Space_Under_High],
                [Block_Space_Under_Wide/2,-Block_Space_Under_High],
                [Block_Space_Upper_Wide/2,0], 
                [Block_Space_Upper_Wide/2,Block_Space_Upper_High],

            ]);
            for (x=[-1,1]) {
                translate([x*Space_Upper_Wide/2, 0])
                circle(r=Blockend_Radius,$fn = circlefn);
            }
            for (x = [-1, 1]) {//爪用溝
                translate([
                    x * Space_Upper_Wide/2,0])
            square([(Blockend_Rail_Nail_Wide)*4,Blockend_Rail_Nail_High],center=true);
        }
        }
        blockendtube();
    }
}


module blockendtube(){
    path_r = (Space_Upper_Wide - Block_Tube_Distance) / 2;
    center_x = (Space_Upper_Wide + Block_Tube_Distance) /4;
    for (x = [-1, 1]) {
        translate([x * center_x, 0, 0])
        rotate([-90, 180, x == 1 ? 180 : 0])
            variable_spiral_tube();
    }
}



module variable_spiral_tube(){//tube接続
    steps = 15;

    for (i = [0 : steps-1]) {
        hull() {
            spiral_ball(i, steps);
            spiral_ball(i+1, steps);
        }
    }
}

module spiral_ball(i, steps) {
    t = i / steps;

    // 巻き角度
    angle = 360 * 0.5 * t;

    // 中心線の巻き半径
    path_r = (Space_Upper_Wide-Block_Tube_Distance)/4;

    // チューブ自体の半径
    tube_r = Ball_radius + (Block_Tube_Radius - Ball_radius) * t;

    translate([
        path_r * cos(angle),
        path_r * sin(angle),
        0
    ])
    sphere(r = tube_r);
}

//ネジ穴
module screw(){
    head = 3.8;
    head_high = 1.2;
    screw_big = 2.3;
    screw_big_high=Block_Space_Upper_High+Blockend_Rail_Nail_High/2;
    screw_thin = 2;
    screw_thin_high = Block_Space_Under_High;
    
    cylinder(h=head_high,d=head,center=false);
    translate([0,0,head_high])
    cylinder(h=screw_big_high,d=screw_big,center=false);
    translate([0,0,head_high+screw_big_high])
    cylinder(h=Block_Space_Under_High,d=screw_thin,center=false);
}

















//レール
module rail(){
    linear_extrude(height = Rail_Thickness)
    difference(){
        square([Rail_Wide,Rail_High],center=true);//レール外径
        translate([0,(Rail_High-Rail_Space_Upper_High)/2])//上側の溝
        square([Rail_Space_Upper_Wide,Rail_Space_Upper_High],center=true);
        translate([0,(Rail_High-2*Rail_Space_Upper_High-Rail_Space_Under_High)/2])//下側溝
        polygon(points=[//下側溝
            [-Rail_Space_Upper_Wide/2,Rail_Space_Under_High/2],//左上
            [-Rail_Space_Under_Wide/2,-Rail_Space_Under_High/2],//左下 
            [Rail_Space_Under_Wide/2,-Rail_Space_Under_High/2],// 右下
            [Rail_Space_Upper_Wide/2,Rail_Space_Under_High/2]// 右上
        ]);      
        for (x = [-1, 1]) {//ボール用溝
            translate([
                x * Space_Upper_Wide/2,
                Rail_High/2-Rail_Space_Upper_High
            ])
            circle(r = Ball_radius, $fn = circlefn);
        }
       
       for (x = [-1, 1]) {//爪用溝
            translate([
                x * Space_Upper_Wide/2,
                Rail_High/2-Rail_Space_Upper_High
            ])
            square([(Rail_Nail_Wide+Rail_Nail_Wide)*2,Rail_Nail_High],center=true);
        }
        
        
        
    }


}    





