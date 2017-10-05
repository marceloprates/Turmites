
import gifAnimation.*;
import controlP5.*;

GifMaker gif;
ControlP5 cp5;

int N,M,states,symbols,symmetry;
float rule_entropy;
PVector[] transitionFunction;
int[][] grid;
PVector position;
PVector direction;
int state;

int speed = 1000;
boolean savingGif = false;

void setup()
{
	size(500,500);
	colorMode(HSB);

	N = M = 500;
	states = 10;
	symbols = 2;
	symmetry = 2;
	rule_entropy = 1;

	position = new PVector(M/2,N/2);
	direction = new PVector(0,1);
	state = 0;

	initGrid();
	initTransitionFunction();

	initGUI();
}

void draw()
{
	loadPixels();
	for(int y = 0; y < height; y++)
	for(int x = 0; x < width; x++)
	{
		int i,j;
		i = int(N*y/height);
		j = int(M*x/width);

		if(symbols == 2)
			pixels[y*width+x] = color(0,0,200*(grid[i][j]));
		else
		{
			if(grid[i][j] == 0)
				pixels[y*width+x] = color(0,0,50);
			else
				pixels[y*width+x] = color(255*float(grid[i][j])/(symbols-1),200,200);
		}
	}
	updatePixels();

	for(int i = 0; i < speed; i++)
		update();

	if(savingGif)
	{
		gif.addFrame();
	}
}

void update()
{
	int read_symbol = grid[(int)position.y][(int)position.x];
	PVector transition = transitionFunction[symbols*state+read_symbol];

	state 				= (int)transition.x;
	int write_symbol 	= (int)transition.y;

	float a = PI/symmetry;
	if((int)transition.z == 0)
	{
		direction = new PVector(cos(a)*direction.x-sin(a)*direction.y,sin(a)*direction.x+cos(a)*direction.y);
	}
	else
	{
		direction = new PVector(cos(-a)*direction.x-sin(-a)*direction.y,sin(-a)*direction.x+cos(-a)*direction.y);
	}

	grid[(int)position.y][(int)position.x] = write_symbol;

	position.add(direction);
	position.y = (position.y+N)%N;
	position.x = (position.x+M)%M;
}

void initGrid()
{
	grid = new int[N][M];
	for(int i = 0; i < N; i++)
	for(int j = 0; j < M; j++)
	{
		grid[i][j] = 0; //random(0,1) < 0.5 ? 0 : 1;
	}
}

void initTransitionFunction()
{
	int quiescentState = int(random(0,symbols));

	transitionFunction = new PVector[states*symbols];
	for(int i = 0; i < states*symbols; i++)
	{
		int state = int(random(0,states));
		int symbol = random(0,1) < rule_entropy ? int(random(0,symbols)) : quiescentState;
		int direction = int(random(0,2));
		transitionFunction[i] = new PVector(state,symbol,direction);
	}
}

void initGUI()
{
	cp5 = new ControlP5(this);

	cp5.addButton("New_Rule")
	.setValue(0)
	.setPosition(0,0)
	.setSize(120,20)
	;

	cp5.addButton("Clear_Board")
	.setValue(0)
	.setPosition(0,21)
	.setSize(120,20)
	;

	cp5.addSlider("States")
	.setPosition(0,42)
	.setSize(120,20)
	.setRange(1,100)
	.setValue(10)
	;

	cp5.addSlider("Symbols")
	.setPosition(0,63)
	.setSize(120,20)
	.setRange(2,50)
	.setValue(1)
	;

	cp5.addSlider("Rule_Entropy")
	.setPosition(0,84)
	.setSize(120,20)
	.setRange(0,1)
	.setValue(1)
	;

	cp5.addSlider("Size")
	.setPosition(0,105)
	.setSize(120,20)
	.setRange(1,height)
	.setValue(height)
	;

	cp5.addSlider("Update_Speed")
	.setPosition(0,126)
	.setSize(120,20)
	.setRange(0,2000)
	.setValue(2000)
	;

	cp5.addButton("Start_Gif")
	.setValue(0)
	.setPosition(0,147)
	.setSize(120,20)
	;

	cp5.addButton("Stop_Gif")
	.setValue(0)
	.setPosition(0,168)
	.setSize(120,20)
	;

	cp5.addButton("Screenshot")
	.setValue(0)
	.setPosition(0,189)
	.setSize(120,20)
	;

	/*
	cp5.addSlider("N_Fold_Symmetry")
	.setPosition(0,210)
	.setSize(120,20)
	.setRange(2,10)
	.setValue(2)
	;
	*/


	// reposition the slider labels

	cp5.getController("States")
	.getCaptionLabel()
	.align(ControlP5.CENTER, ControlP5.CENTER)
	;

	cp5.getController("Symbols")
	.getCaptionLabel()
	.align(ControlP5.CENTER, ControlP5.CENTER)
	;
	
	cp5.getController("Rule_Entropy")
	.getCaptionLabel()
	.align(ControlP5.CENTER, ControlP5.CENTER)
	;

	cp5.getController("Size")
	.getCaptionLabel()
	.align(ControlP5.CENTER, ControlP5.CENTER)
	;

	cp5.getController("Update_Speed")
	.getCaptionLabel()
	.align(ControlP5.CENTER, ControlP5.CENTER)
	;

	/*
	cp5.getController("N_Fold_Symmetry")
	.getCaptionLabel()
	.align(ControlP5.CENTER, ControlP5.CENTER)
	;
	*/
}

public void New_Rule() 
{

	initTransitionFunction();
}

public void Clear_Board(int x)
{

	initGrid();
}

public void States(int x)
{
	states = x;
	state = 0;
	initTransitionFunction();
}

public void Symbols(int x)
{
	symbols = x;
	initGrid();
	initTransitionFunction();
}

public void Rule_Entropy(float x)
{
	rule_entropy = x;
	initTransitionFunction();
}

public void Size(int x)
{
	N = M = x;
	position = new PVector(M/2,N/2);
	direction = new PVector(0,1);
	state = 0;
	initGrid();
}

public void Update_Speed(int x)
{

	speed = x;
}

public void Start_Gif() 
{
	savingGif = true;

	gif = new GifMaker(this, String.format("turmite-%d.gif",(int)random(0,Integer.MAX_VALUE-1)));
  	gif.setRepeat(0); // make it an "endless" animation
  	//gif.setQuality(20);
  	gif.setDelay(50);
}

public void Stop_Gif() 
{
	savingGif = false;

	gif.finish();
}

public void Screenshot()
{

	saveFrame(String.format("turmite-%d.png",int(random(0,Integer.MAX_VALUE-1))));
}

public void N_Fold_Symmetry(int x)
{

	symmetry = x;
}

public void mouseDragged()
{
	int R = 10;

	int x,y;
	y = int(N*mouseY/height);
	x = int(M*mouseX/width);

	for(int i = max(0,y-R); i < min(N-1,y+R); i++)
	for(int j = max(0,x-R); j < min(M-1,x+R); j++)
	if(pow(i-y,2)+pow(j-x,2) < pow(R,2))
	{
		grid[i][j] = 1;
	}
}