unit pmlib;

interface
uses pmg;

var
	p0Data : array [0.._P_MAX] of byte = (0,0,0,0,32,24,140,255,140,24,32,0,0,0,0);
	p1Data : array [0.._P_MAX] of byte = (0,28,28,56,252,255,240,224,240,60,59,24,4,4,6);
	p2Data : array [0.._P_MAX] of byte = (60,102,110,118,118,118,102,60,24,0,0,0,0,0,0);
	p3Data : array [0.._P_MAX] of byte = (10, 20, 30, 40, 50, 60, 70, 80, 55, 28, 255,0, 0, 0, 0);
	
	p0Data1 : array [0.._P_MAX] of byte = (0,0,0,0,103,99,61,3,7,227,219,15,6,0,0);
	p1Data1 : array [0.._P_MAX] of byte =  (0,240,112,224,240,240,242,204,240,232,118,12,4,2,3);

	p0PosX: word =80;
	p0PosY: byte =57;
procedure loadPlayers;
procedure swap;
procedure movePlayer(x: smallint; y: smallint); overload;
implementation

procedure swap;
begin
{	if p_data[0]=@p0Data then begin
		p_data[0]:=@p0Data1;
		p_data[1]:=@p1Data1;
	end
	else begin
		p_data[0]:=@p0Data;
		p_data[1]:=@p1Data;
	end;
}
end;

procedure movePlayer(x: smallint; y: smallint); overload;
begin
	p0PosX:=p0PosX + x;
	p0PosY:=p0PosY + y;
//	inc(p0PosX);
//	inc(p0PosY);
	MoveP(0, p0PosX, p0PosY);
end;


procedure loadPlayers;
begin
	
	p_data[0]:=@p0Data;
//	p_data[1]:=@p1Data;
//	p_data[2]:=@p2Data;
//	p_data[3]:=@p3Data;


	// Initialize P/M graphics
	SetPM(_PM_SINGLE_RES);
	InitPM(_PM_SINGLE_RES);  
	//Poke(106,Peek(106)-8);
	// Priority register - P/M in front of all playfield
	Poke(623, 33);

	// Turn on P/M graphics
	ShowPM(_PM_SHOW_ON);    
  // Draw players
  ColorPM(0, 6);
//  ColorPM(1, 6);
// ColorPM(2, 136);
//  ColorPM(3, 36);

  SizeP(0, _PM_NORMAL_SIZE);
  SizeP(1, _PM_NORMAL_SIZE);
//  SizeP(2, _PM_QUAD_SIZE);
//  SizeP(3, _PM_NORMAL_SIZE);

  MoveP(0, p0PosX, p0PosY);
//  MoveP(1, 88, 65);
//  MoveP(2, 100, 85);
//  MoveP(3, 140, 100);
 

	// Reset P/M graphics
	//ShowPM(_PM_SHOW_OFF);        

end;

end.

