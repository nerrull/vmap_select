//Christian Attard
//2015 @ introwerks 
//Press 's' to export

//Modified by Etienne Richan

/* Controls
  Click and drage to paint the effect onto the image

  Keys:
  - : reduce depth
  = : increase depth
  c : iterate through channels 
  f : toggle fill
  s : toggle stroke
  m : switch mode (pyramids or boxes)
  [ : Reduce sample size
  ] : Increase sample size
  _ : Reduce brush size
  + : Increase brush size
  e : export frame  -> you can change the file extension on line 276 to whatever you want (png, jpg, etc)
  
  1 : Set brush to paint effect
  2 : Set brush to erase effect


*/

import peasy.*;
PeasyCam cam;

final static int BLACK = 0;
final static int IMAGE = 1;
final static int NONE = 2;


final static int RED = 0;
final static int GREEN = 1;
final static int BLUE = 2;
final static int HUE = 3;
final static int SATURATION = 4;
final static int BRIGHTNESS = 5;
final static int NRED = 6;
final static int NGREEN = 7;
final static int NBLUE = 8;
final static int NHUE = 9;
final static int NSATURATION = 10;
final static int NBRIGHTNESS = 11;


final static int BLOCKS = 0;  
final static int PYRAMIDS = 1;


PImage img;
String name = "glasses"; //file name 
String type = "jpg"; //file type

float depth;
int count = int(random(666));

// modes: BLOCKS, PYRAMIDS. 
int mode = BLOCKS; 

// shape size.
int vSize = 10; 


// fill & stroke types: BLACK, IMAGE, NONE.
int fill_type = IMAGE;
int stroke_type = NONE;


// channels for depth: RED, GREEN, BLUE, HUE, SATURATION, BRIGHTNESS, NRED, NGREEN, NBLUE, NHUE, NSATURATION, NBRIGHTNESS. 
int channel = BRIGHTNESS;
// depth ammount.
float channel_weight = 0.5;

float depthMultiplier = 1.0;

int circleWidth = 50;

int circleOffsetX =0;
int circleOffsetY = 0;

PGraphics circleImage;

boolean SINGLE_CIRCLE = false;

void setup() {
  img = loadImage(name + "." + type);
  //img.resize (img.width/2, img.height/2);
  //cam = new PeasyCam(this, 1000);
  size(img.width, img.height, P3D);
  circleOffsetX = width/2;
  circleOffsetY = height/2;
  circleImage = createGraphics(width, height);
  println("christian attard, 2015 @ introwerks");
}


float getChannel(color c) {
  int ch = channel>5?channel-6:channel;
  float cc;

  switch(ch) {
  case RED: 
    cc = red(c); 
    break;
  case GREEN: 
    cc = green(c); 
    break;
  case BLUE: 
    cc = blue(c); 
    break;
  case HUE: 
    cc = hue(c); 
    break;
  case SATURATION: 
    cc = saturation(c); 
    break;
  default: 
    cc= brightness(c); 
    break;
  }

  return channel_weight * (channel>5?255-cc:cc);
}

color black = color(0,0,0);
color white = color(255,255,255);
color brush = black;
boolean UPDATE = true;
void draw() {
  if (UPDATE)
  {
  background(img);
  lights();
  
  circleImage.beginDraw();
  circleImage.noStroke();
  circleImage.fill(brush);
  circleImage.ellipse(circleOffsetX , circleOffsetY, circleWidth, circleWidth);
  circleImage.endDraw();
  circleImage.loadPixels();

  for (int i =0; i<width - 1; i+=vSize) {
    for (int j =0; j<height -1; j+=vSize) {
      ///int pos =circleOffsetX + i +(circleOffsetY +j)*width;
      if (circleImage.pixels[i + (j*width)] == black)
      {

        switch(mode) {
        case 0:
          blocks(i, j);
          break;
        case 1:
          pyramids(i, j);
          break;
        }
      }
    }
  }

  if (SINGLE_CIRCLE)
  {
    circleImage.beginDraw();
    circleImage.fill(255,255,255);
    circleImage.ellipse(circleOffsetX + circleWidth/2, circleOffsetY +circleWidth/2, circleWidth, circleWidth);
    circleImage.endDraw();
  }
  UPDATE = false;
}
}

// blocks
void blocks(int x, int y) {  
  color c = img.pixels[x+(y*width)];
  depth = getChannel(c) * depthMultiplier;
  pushMatrix();
  switch(fill_type) {
  case BLACK:
    fill(0);
    break;
  case IMAGE:
    fill(c);
    break;
  case NONE:
    noFill();
    break;
  }
  switch(stroke_type) {
  case BLACK:
    stroke(0);
    break;
  case IMAGE:
    stroke(c);
    break;
  case NONE:
    noStroke();
  }
  translate(x+(vSize/2), y+(vSize/2), -20);
  box(vSize, vSize, depth);
  popMatrix();
}


// pyramids
void pyramids(int x, int y) {
  color c = img.pixels[x+(y*width)];
  depth = getChannel(c) * depthMultiplier;
  pushMatrix();
  switch(fill_type) {
  case BLACK:
    fill(0);
    break;
  case IMAGE:
    fill(c);
    break;
  case NONE:
    noFill();
    break;
  }
  switch(stroke_type) {
  case BLACK:
    stroke(0);
    break;
  case IMAGE:
    stroke(c);
    break;
  case NONE:
    noStroke();
  }
  translate(x, y);
  beginShape(TRIANGLE);
  vertex(0, 0, 0);
  vertex(0, vSize, 0);
  vertex(vSize/2, vSize/2, depth);

  vertex(0, vSize, 0);
  vertex(vSize, vSize, 0);
  vertex(vSize/2, vSize/2, depth);

  vertex(vSize, vSize, 0);
  vertex(vSize, 0, 0);
  vertex(vSize/2, vSize/2, depth);

  vertex(vSize, 0, 0);
  vertex(0, 0, 0);
  vertex(vSize/2, vSize/2, depth);
  endShape(CLOSE);
  popMatrix();
}

void mouseClicked(){
  circleOffsetX = mouseX;
  circleOffsetY = mouseY;
  correctOffset();
  UPDATE = true;
}

void mouseDragged(){
  circleOffsetX = mouseX;
  circleOffsetY = mouseY;
  correctOffset();
  UPDATE = true;
}

void correctOffset()
{
  circleOffsetX = min(circleOffsetX, width -circleWidth);
  circleOffsetY = min(circleOffsetY, height -circleWidth);
  circleOffsetX = max(circleOffsetX, 0);
  circleOffsetY = max(circleOffsetY, 0);
}

// export
void keyPressed() {
  UPDATE = true;
  if (key == 'e') {
    saveFrame("out/" + name +"/" + "f_###########.gif");
    println("export");
  }

  if (key == '='){
    depthMultiplier +=0.1;
  }
  if (key == '-'){
    depthMultiplier -=0.1;
  }
  if (key == 'c'){
    channel = (channel+1) % 12;
  }
  if (key =='f'){
    fill_type = (fill_type+1) %3;
  }
  if (key =='s'){
    stroke_type= (stroke_type+1) %3;
  }
  if (key =='m'){
    mode= (mode+1) %2;
  }
  if (key =='[')
  {
    vSize = max(1, vSize-1);
  }
  if (key ==']')
  {
    vSize += 1;
  }

  if (key =='_')
  {
    circleWidth = max(1, circleWidth-1);
  }
  if (key =='+')
  {
    circleWidth += 1;
  }

  if (key == '1'){
    brush = black;
    UPDATE = false;
  }
  if (key == '2'){
    brush = white;
    UPDATE = false;
  }

}
