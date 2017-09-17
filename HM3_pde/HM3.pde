import processing.serial.*;
import java.util.Scanner;


Serial myPort;        // The serial port

int ballcount= 30;
int Bulletcount = 10;
Ball []myBall;
Bullet[]myBullet;
int score, scoreLevle1, scoreLevle2, scoreLevle3, mode1, mode2, mode3, sightWeight, usedBullet;
color sightColor;
boolean Win, noBullet;
int CurrentFrameCount;
float speed1 = 0.05;
float speed2 = 0.10;
int step = 10;
String clickSide;
String fire = "FIRE";
String reload = "RELOAD";

//int testx,testy;

void setup() {
  //size(410, 400);
  fullScreen();
  frameRate(120);
  smooth();
  background(0);
  sightColor = #FF0818;
  sightWeight=2;
  myBall = new Ball[ballcount];
  for (int i =0; i < ballcount; i++) {
    myBall[i] = new Ball(random(20, width-20), random(20, height-20), random(1, 3), random(1, 3));
  }

  myPort = new Serial(this, "/dev/cu.usbserial-A106TEXG", 9600);
  //myPort = new Serial(this, "/dev/cu.usbserial-A106TEXG", 38400);

  //testx = 0;
  //testy = 0;
}


int updateMousePosition(float accV, int mouse, int screenAxisSize) {
  int result = mouse;
  if (mouse <= screenAxisSize && mouse >= 0) {
    if (accV > speed1 && accV< speed2) {
      result += step;
    } else if (accV>= speed2) {
      result += 2*step;
    } else if (accV < -speed1 && accV> -speed2) {
      result -= step;
    } else if (accV <= -speed2) {
      result -= step*2;
    }
  } else if (mouse<0) {
    result = 0;
  } else if (mouse > screenAxisSize) {
    result = screenAxisSize;
  }
  return result;
}


void draw() {
  //testx += 10;
  //testy += 10;

  String inString = myPort.readStringUntil('\n');
  if (inString != null) {

    //println(inString);
    inString = trim(inString);

    float x, y;
    String[] tmp = split(inString, ",");
    if (tmp.length == 3) {
      x = float(tmp[0]);
      y = float(tmp[1]);
      //z = float(tmp[2]);
      //println("xAcc = "+ x + " yAcc = "+ y);

      mouseX = updateMousePosition(x, mouseX, width);
      mouseY = updateMousePosition(y, mouseY, height);
    } else if (int(inString) == 2 || int(inString)==1 || int(inString)==3 ) {

      int inInt = int(inString);
      println(inString+":"+inInt+"");
      if (inInt == 1) {
        clickSide = "LEFT";
        println("LEFFFFFT");
        mousePressed();
      } else if (inInt == 2) {
        clickSide = "RIGHT";
        println("RIIIIIGHT");
        mousePressed();
      } else if (inInt == 3) {
        mouseReleased();
      }
    }
  } 

  background(0);
  winScore();
  sight(); 
  Win=true;
  myBullet = new Bullet[Bulletcount- usedBullet];
  for (int i =0; i < Bulletcount-usedBullet; i++) {
    myBullet[i] = new Bullet(width-50, i*15+230);
  }
  for (int i =0; i < ballcount; i++) {
    if ( !myBall[i].hit) {//如果20个球中任意一个球没有被命中，则显示这个球
      myBall[i].move();
      myBall[i].display();
      Win= false;
    }
  }
  for (int i =0; i < Bulletcount- usedBullet; i++) {
    myBullet[i].display();
  }
  if (Win) {
    textAlign(CENTER, CENTER);
    fill(0);
    rect(0, 0, width, height);
    fill(#FA7900);
    textSize(32);
    text("YOU WIN !", width/2, height/2-50);
    text("your score is "+score, width/2, height/2);
  }
  //  println("mode1="+mode1+" /  mode2="+mode2+" /  mode3="+mode3+"  /   score="+score);
  //  println("mode1+mode2+mode3="+(mode1+mode2+mode3));
  // println("leftBullet="+(Bulletcount-usedBullet)+"   usedBullet="+usedBullet);
  //  println(CurrentFrameCount+"   "+frameCount);
}

void mousePressed() {
  sightColor = #FFD603;
  sightWeight=3;
  //sight();
  for (int i =0; i < ballcount; i++) {
    if (dist(mouseX, mouseY, myBall[i].x, myBall[i].y)<40 && dist(mouseX, mouseY, myBall[i].x, myBall[i].y)>30 &&  clickSide == "LEFT" && usedBullet>=0 && usedBullet<10 ) {
      scoreLevle1=6;
      mode1++;
    } else if (dist(mouseX, mouseY, myBall[i].x, myBall[i].y)<=30 && dist(mouseX, mouseY, myBall[i].x, myBall[i].y)>20 && clickSide == "LEFT" && usedBullet>=0 && usedBullet<10 ) {
      scoreLevle2=8;
      mode2++;
    } else if (dist(mouseX, mouseY, myBall[i].x, myBall[i].y)<=20 && clickSide == "LEFT" && usedBullet>=0 && usedBullet<10 ) {
      scoreLevle3=10;
      mode3++;
    }
  }
  if (clickSide == "LEFT" && usedBullet>9 ) {
    noBullet=true;
    CurrentFrameCount=frameCount;
  }
  checkHit();
  if (clickSide == "LEFT" ) {
    usedBullet++;
    if ( usedBullet>10) {
      Bulletcount=usedBullet;
    }
  }
  if (clickSide == "RIGHT" && usedBullet>=10) {
    Bulletcount=10;
    usedBullet=0;
  }
}



void winScore() {
  score= scoreLevle1*mode1+scoreLevle2*mode2+scoreLevle3*mode3;
  textAlign(LEFT, CENTER);
  textSize(22);
  fill(#FA7900);
  text("Your score is : "+score, 15, 15);
  textSize(12);
  fill(255);
  if (frameCount<160) {
    text("Press left mouse button to fire. Press right mouse button to reload.", 15, 40);
  }
  if (usedBullet>9) {
    if (frameCount-CurrentFrameCount<160) {
      text("Press right mouse button to reload.", 15, 40);
    }
  }
}

void checkHit() {
  for (int i =0; i < ballcount; i++) {
    if (dist(mouseX, mouseY, myBall[i].x, myBall[i].y)<40 && clickSide == "LEFT" && usedBullet>=0 && usedBullet<10 ) {
      myBall[i].hit=true;
    }
  }
}

void sight() {
  pushStyle();
  noCursor();
  noFill();
  strokeWeight(sightWeight);
  stroke(sightColor);
  //ellipse(testx, testy, 30, 30);
  ellipse(mouseX, mouseY, 45, 45);
  line(mouseX-45, mouseY, mouseX+45, mouseY);
  line(mouseX, mouseY-45, mouseX, mouseY+45);
  popStyle();
}

void mouseReleased() {
  sightColor = #FF0818;
  sightWeight=2;
}

class Ball {
  float x, y;
  float vX, vY;
  color c1, c2, c3;
  boolean hit;

  Ball(float temp_x, float temp_y, float temp_vX, float temp_vY) {
    x =temp_x;
    y =temp_y;
    vX=temp_vX;
    vY=temp_vY;
    c3=#064A9B;
    c2=#2886D1;
    c1=#47C0E3;
    noStroke();
  }

  void move() {
    x+=vX;
    y+=vY;
    if (x>width-20 ) {
      vX*=-1;
      x=width-20;
    } else if (x<20) {
      vX*=-1;
      x=20;
    }
    if (y>height-20 ) {
      vY*=-1;
      y=height-20;
    } else if (y<20) {
      vY*=-1;
      y=20;
    }
  }

  //Old sizes 40,24,8
  void display() {
    fill(c3, 110);
    ellipse(x, y, 80, 80);
    fill(c2, 100);
    ellipse(x, y, 48, 48);
    fill(c1, 120);
    ellipse(x, y, 16, 16);
  }
}

class Bullet {
  int x, y;

  Bullet(int posx, int posy) {
    x = posx;
    y = posy;
  }

  void checkShooting() {
  }

  void display() {
    fill(#D6D6D6);
    rect(x, y, 30, 5);
  }
}