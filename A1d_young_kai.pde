/*
===================================================================

Kai Young
SCIMA 300
A1d_young_kai

This sketch uses the code from Chapter 4 of Visualizing Data by 
Ben Fry. Chapter 4 deals with time series visualizations. The
original code visualize U.S. consumption of Coffee, Tea and
Milk.

Initially I attempted to use data I had collected for Assignment
1a but that set did not lend itself very well to time series.

I went online and searched for data that was based annually. I 
found three data sets at 

https://datamarket.com/data

The sets were organized by year and I choose to look at annual
rainfall, sheep population and barley yield, all in England.

The sets are not related in a way that provides insight into the
data but they are organized in a way that allowed me to dig 
into the code and try and reproduce the visualization.

Using if statements I changed the side titles. I also changed the
font and the color of the fills for the data area.

===================================================================
*/

FloatTable data;
float dataMin, dataMax;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int rowCount;
int columnCount;
int currentColumn = 0;

int yearMin, yearMax;
int[] years;

int yearInterval = 10;
int volumeInterval = 10;
int volumeIntervalMinor = 5;

float[] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 10;

Integrator[] interpolators;

PFont plotFont;

void setup() {
  size(720, 405);
  data = new FloatTable("rain-barley-sheep.tsv");
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();

  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length-1];

  dataMin = 0;
  dataMax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;

  interpolators = new Integrator[rowCount];
  for (int row = 0; row<rowCount; row++) {
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    interpolators[row].attraction = .1;
  }

  plotX1 = 120;
  plotX2 = width-80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height-25;

  plotFont = loadFont("BrandonGrotesque-Medium-25.vlw");
  textFont(plotFont);

  smooth();
}

void draw() {
  background(255);
  //show the plot area as white box
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);

  drawTitleTabs();
  drawAxisLabels();

  for (int row = 0; row<rowCount; row++) {
    interpolators[row].update();
  }

  drawYearLabels();
  drawVolumeLabels();

  noStroke();
  if (currentColumn == 0) {
  fill(#5679C1);
  }
  if (currentColumn == 1) {
  fill(#51BCCE);
  }
  if (currentColumn == 2) {
  fill(#6B51CE);
  }
  drawDataArea(currentColumn);
}

void drawTitleTabs() {
  rectMode(CORNERS);
  noStroke();
  textSize(25);
  textAlign(LEFT);
  //onthe first use of this method allocate space for an array
  //to store the values for the left and right edges of the tabs
  if (tabLeft == null) {
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15;
  tabBottom = plotY1;

  for (int col = 0; col<columnCount; col++) {
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad +titleWidth + tabPad;

    // if the current tab sets its bg white, otherwise use grey
    fill(col ==currentColumn ? 255:224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    //if the current tab, use black for the text, otherwise grey
      if (currentColumn == 0) {
      fill(#5679C1);
      }
      if (currentColumn == 1) {
      fill(#51BCCE);
      }
      if (currentColumn == 2) {
      fill(#6B51CE);
      }    
    text(title, runningX+tabPad, plotY1-10);
    runningX = tabRight[col];
  }
}

void mousePressed() {
  if (mouseY>tabTop && mouseY<tabBottom) {
    for (int col = 0; col<columnCount; col++) {
      if (mouseX>tabLeft[col] && mouseX<tabRight[col]) {
        setColumn(col);
      }
    }
  }
}

void setColumn(int col) {
  currentColumn = col;
  for (int row = 0; row<rowCount; row++) {
    interpolators[row].target(data.getFloat(row, col));
  }
}

void drawAxisLabels() {
  fill(0);
  textSize(13);
  textLeading(15);

  textAlign(CENTER, CENTER);
  if(currentColumn == 0){
  text("Annual\nrainfall\nin inches\nin Nottingham", labelX, (plotY1+plotY2)/2);
  }
  if(currentColumn == 1){
  text("Annual\nbarley yeilds\nper acre\nin England", labelX, (plotY1+plotY2)/2);
  }
  if(currentColumn == 2){
  text("Annual\nsheep population\n(1000s)\nin England", labelX, (plotY1+plotY2)/2);
  }
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
}

void drawYearLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER);

  //grid
  stroke(224);
  strokeWeight(1);

  for (int row = 0; row<rowCount; row++) {
    if (years[row]% yearInterval ==0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row],x, plotY2+textAscent()+10);
      line(x, plotY1, x, plotY2);
    }
  }
}

void drawVolumeLabels() {
  fill(0);
  textSize(10);
  textAlign(RIGHT);

  stroke(128);
  strokeWeight(1);

  for (float v = dataMin; v<dataMax; v+= volumeIntervalMinor) {
    if (v%volumeIntervalMinor ==0) {
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if (v%volumeInterval == 0) {
        float textOffset = textAscent()/2;
        if (v == dataMin) {
          textOffset = 0;
        } else if (v == dataMax) {
          textOffset = textAscent();
        }
        text(floor(v), plotX1-10, y+textOffset);
        line(plotX1-4, y, plotX1, y);
      } else {
        //line...
      }
    }
  }
}
void drawDataArea(int col) {
  beginShape();
  for (int row=0; row<rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = interpolators[row].value;
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x, y);
    }
  }
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);
}