/*
Programmed by Kaoru ASHIHARA

Thanks to AWAY3D ( http://away3d.com/ )

Copyright AIST, 2016
*/

package
{
	// -------------------------------------------------------------------------------------------------------------------------------
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.filesystem.File;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.media.Video;
	import flash.net.FileFilter;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;
	import flash.utils.getTimer;
	
	import SopaBeamer;
	
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	
	[SWF(width=720,height=360,framerate=30)]
	
	// -------------------------------------------------------------------------------------------------------------------------------		
	
	// -------------------------------------------------------------------------------------------------------------------------------
	public class SopaAir extends Sprite
	{
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private var sopaStreamer:SopaBeamer;
		private var cardBtn:Sprite;
		private var loadBtn:Sprite;
		private var playBtn:Sprite;
		private var textFormat:TextFormat = new TextFormat();
		private var titleFormat:TextFormat = new TextFormat();
		private var myTitle:TextField = new TextField();
		private var myTextField:TextField = new TextField();
		private var secondTextField:TextField = new TextField();
		private var sopaURL:String = "https://unit.aist.go.jp/hiri/hi-infodesign/as_still/cygne22k.sopa";
//		private var sopaURL:String = "Enter the URL of a SOPA file";
		private var instText:TextField = new TextField();
		private var infoText:TextField = new TextField();
		private var playText:TextField = new TextField();
		private var messageField:TextField = new TextField();
		private var ns_front:NetStream;
		private var ns_right:NetStream;
		private var ns_back:NetStream;
		private var ns_left:NetStream;
		private var ns_top:NetStream;
		private var ns_bottom:NetStream;
		
		private var nc_front:NetConnection;
		private var nc_right:NetConnection;
		private var nc_back:NetConnection;
		private var nc_left:NetConnection;
		private var nc_top:NetConnection;
		private var nc_bottom:NetConnection;
		
		private var skyBox:SkyBox; 
		private var view:View3D;
		
		private var video_front:Video;
		private var videoContainer_front:Sprite;
		private var video_right:Video;
		private var videoContainer_right:Sprite;
		private var video_back:Video;
		private var videoContainer_back:Sprite;
		private var video_left:Video;
		private var videoContainer_left:Sprite;
		private var video_top:Video;
		private var videoContainer_top:Sprite;
		private var video_bottom:Video;
		private var videoContainer_bottom:Sprite;
		
		private var bmpDataFront:BitmapData;
		private var bmpDataRight:BitmapData;
		private var bmpDataBack:BitmapData;
		private var bmpDataLeft:BitmapData;
		private var bmpDataTop:BitmapData;
		private var bmpDataBottom:BitmapData;
		
		private var bmpTextureFront:Texture2DBase;
		private var bmpTextureRight:Texture2DBase;
		private var bmpTextureBack:Texture2DBase;
		private var bmpTextureLeft:Texture2DBase;
		private var bmpTextureTop:Texture2DBase;
		private var bmpTextureBottom:Texture2DBase;
		
		private var planeTextureFront:TextureMaterial;
		private var planeTextureRight:TextureMaterial;
		private var planeTextureBack:TextureMaterial;
		private var planeTextureLeft:TextureMaterial;
		private var planeTextureTop:TextureMaterial;
		private var planeTextureBottom:TextureMaterial;
		
		private var planeGeom:PlaneGeometry;
		private var planeFront:Mesh;
		private var planeRight:Mesh;
		private var planeLeft:Mesh;
		private var planeBack:Mesh;
		private var planeTop:Mesh;
		private var planeBottom:Mesh;
		
		private var videoW:Number = 512;
		private var videoH:Number = 512;
		private var nThresholdX:Number;
		private var nThresholdY:Number;
		private var sizeUnit:Number;
		private var iCountVideo:int;
		private var timeIni:int;
		private var timeElapsed:int;
		private var horizontalAngle:Number = 0.0;
		private var verticalAngle:Number = 0.0;
		private const SENS:Number = 2.0;
		private const PLANE_NUM:int = 6;
		private const WIDTH:int = 720;
		private const HEIGHT:int = 360;
		
		private var isOut:Boolean;
		private var isPlaying:Boolean;
		private var isMotion:Boolean = false;
		private var isPngOK:Boolean = false;
		private var isDefault:Boolean = false;
		
		[Embed(source = "x_cursor.png"] private static const xCursor:Class;
		[Embed(source = "up_cursor.png"] private static const upCursor:Class;
		[Embed(source = "down_cursor.png"] private static const downCursor:Class;
		[Embed(source = "left_cursor.png"] private static const leftCursor:Class;
		[Embed(source = "right_cursor.png"] private static const rightCursor:Class;
		[Embed(source = "default_cube.png"] private static const embeddedImage:Class;
		
		// ---------------------------------------------------------------------------------------------------------------------------				
		
		// ---------------------------------------------------------------------------------------------------------------------------
		public function SopaAir()
		{
			// Setup class specific tracer
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			nThresholdX = WIDTH / 4;
			nThresholdY = HEIGHT / 4;
			
			iCountVideo = 0;
			isOut = false;
			isPlaying = false;
			sizeUnit = stage.stageWidth / 800;
			
			this.addEventListener(Event.ADDED_TO_STAGE,init);
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		// ---------------------------------------------------------------------------------------------------------------------------
		public function init(e:Event=null):void
		{	
			var iMargin:int = stage.stageHeight / 28;
			
			// Clean up stage added listener
			this.removeEventListener(Event.ADDED_TO_STAGE,init);
			stage.color = 0x006633;
			
			titleFormat.color = 0xffff33;
			titleFormat.size = 28;
			titleFormat.align = TextFormatAlign.CENTER;
			titleFormat.font = "Berlin Sans FB";
			
			textFormat.color = 0xffffff;
			textFormat.size = 20;
			textFormat.align = TextFormatAlign.CENTER;
			
			// Setup Away3D 4
			setupAway3D();
			
			// Setup video material (which is next to the same as making a video player via netstream)
			setupVideoMaterial();
			
			// Build our Away3D 4 scene
			buildScene();
			
			secondTextField.autoSize = TextFieldAutoSize.CENTER;
			secondTextField.y = iMargin;
			secondTextField.defaultTextFormat = textFormat;
			secondTextField.text = "Click to open dialog or";
			secondTextField.x = (WIDTH - secondTextField.width) / 2;
			secondTextField.filters = [new DropShadowFilter()];

			loadBtn = new Sprite();
			loadBtn.graphics.beginFill(0x00CC00);
			loadBtn.graphics.drawRoundRect
				((WIDTH - secondTextField.width) / 2,iMargin,secondTextField.width,secondTextField.height,8);
			loadBtn.graphics.endFill();
			loadBtn.useHandCursor = true;
			loadBtn.buttonMode = true;
			loadBtn.mouseChildren = false;
			loadBtn.alpha = 0.5;
			loadBtn.addEventListener(MouseEvent.CLICK, searchFile);			
			loadBtn.addChild(secondTextField);
			
//			myTextField.autoSize = TextFieldAutoSize.CENTER;
			myTextField.width = WIDTH - iMargin * 2;
			myTextField.border = true;
			myTextField.y = iMargin * 2 + secondTextField.height;
			myTextField.defaultTextFormat = textFormat;
			myTextField.text = "Enter the URL of a SOPA file";
			myTextField.height = secondTextField.height;
			myTextField.type = "input";
			myTextField.x = (WIDTH - myTextField.width) / 2;
			myTextField.filters = [new DropShadowFilter()];
			myTextField.addEventListener(MouseEvent.MOUSE_DOWN, check_url);
			
			myTitle.autoSize = TextFieldAutoSize.CENTER;
			myTitle.defaultTextFormat = titleFormat;
			myTitle.blendMode = BlendMode.LAYER;
			myTitle.filters = [new DropShadowFilter()];
			myTitle.text = "Panoramic sound player, SopaAir";
			myTitle.x = (WIDTH - myTitle.width) / 2;
			myTitle.y = iMargin + secondTextField.height * 3;
			myTitle.alpha = 1.0;
			
			instText.defaultTextFormat = textFormat;
			instText.text = " Turn on Cardioid ";
			instText.autoSize = TextFieldAutoSize.LEFT;
			instText.x = (WIDTH - instText.width) / 2;
			instText.y = HEIGHT / 2 + instText.height;
			instText.textColor = 0xffff99;
			instText.filters = [new DropShadowFilter()];
			
			infoText.defaultTextFormat = textFormat;
			infoText.text = "Omnidirectional";
			infoText.autoSize = TextFieldAutoSize.CENTER;
			infoText.x = (WIDTH - infoText.width) / 2;
			infoText.y = HEIGHT / 2 + instText.height * 2.5;
			infoText.textColor = 0x66ffcc;
			infoText.filters = [new DropShadowFilter()];
			
			cardBtn = new Sprite();
			cardBtn.graphics.beginFill(0x00CC00);
			cardBtn.graphics.drawRoundRect
				(instText.x,instText.y,instText.width,instText.height,8);
			cardBtn.graphics.endFill();
			cardBtn.useHandCursor = true;
			cardBtn.buttonMode = true;
			cardBtn.mouseChildren = false;
			cardBtn.alpha = 0.5;
			cardBtn.addEventListener(MouseEvent.CLICK, check_key);
			cardBtn.addChild(instText);
			
			playText.defaultTextFormat = textFormat;
			playText.text = "Not ready";
			playText.autoSize = TextFieldAutoSize.CENTER;
			playText.x = (WIDTH - playText.width) / 2;
			playText.y = HEIGHT / 2 - playText.height;
			playText.textColor = 0xffffff;
			playText.filters = [new DropShadowFilter()];
			
			playBtn = new Sprite();
			playBtn.graphics.beginFill(0x00CC00);
			playBtn.graphics.drawRoundRect
				(playText.x,playText.y,playText.width,playText.height,8);
			playBtn.graphics.endFill();
			playBtn.useHandCursor = true;
			playBtn.buttonMode = true;
			playBtn.mouseChildren = false;
			playBtn.alpha = 0.5;
			playBtn.addEventListener(MouseEvent.CLICK, onPlay);
			playBtn.addChild(playText);
			
			messageField.defaultTextFormat = textFormat;
			messageField.text = "SopaAir version 1.0, Copyright 2016 AIST";
			messageField.autoSize = TextFieldAutoSize.CENTER;
			messageField.x = WIDTH - messageField.width - iMargin;
			messageField.y = HEIGHT - messageField.height * 1.6;
			messageField.textColor = 0x66ffcc;
			messageField.filters = [new DropShadowFilter()];
			
			addChild(myTitle);
			addChild(myTextField);
			addChild(infoText);
			addChild(messageField);
			addChild(cardBtn);
			addChild(loadBtn);
			addChild(playBtn);
			
			sopaStreamer = new SopaBeamer();
			horizontalAngle = verticalAngle = 0;
			sopaStreamer.isFocusOn = false;
			
			// Listen up!
			initEventListeners();
			
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function searchFile(e:MouseEvent):void{
			var fileToOpen:File = new File();
			var txtFilter:FileFilter = new FileFilter("SOPA", "*.sopa"); 
			
			try{
				fileToOpen.browseForOpen("Open", [txtFilter]); 
				fileToOpen.addEventListener(Event.SELECT, fileSelected); 
				fileToOpen.addEventListener(Event.CANCEL, fileCancelled); 
			}catch (error:Error){
				messageField.text = "Open file error!";
			}
		}
		
		private function fileCancelled(event:Event):void{
			secondTextField.text = "File not selected";
			stage.focus = myTextField;
		}
		
		private function fileSelected(event:Event):void 
		{
			var path:File = event.target as File;
			sopaURL = path.url;
			myTextField.text = sopaURL;
			
			sopaStreamer.sopaURL = sopaURL;
			sopaStreamer.nSamplesDone = 0;
			sopaStreamer.sopaPrepare();
			
			var isReadyToPlay:Boolean = sopaStreamer.isPrepared;
			var isSopaFailed:Boolean = sopaStreamer.isFailed;
			while(!isReadyToPlay && !isSopaFailed && !sopaStreamer.isReady){
				var iLap:int = getTimer();
				isReadyToPlay = sopaStreamer.isPrepared;
				isSopaFailed = sopaStreamer.isFailed;
			}	
			if(sopaStreamer.isFailed){
				secondTextField.text = "Failed to load data!";
			}
			else{
				if(!view.scene.contains(planeFront)){
					// Build our Away3D 4 scene
					buildScene();					
				}
				secondTextField.text = "Please wait for a while";
				runVideo();
				createNativeCursor();
				
			}
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function check_url(e:Event):void 
		{
			if(myTextField.text == "Enter the URL of a SOPA file")
				myTextField.text = "";
		}
		
		private function createNativeCursor() : void {
			var xCursorData:MouseCursorData = new MouseCursorData();
			var xBitmapDatas:Vector.<BitmapData> = new <BitmapData>[new xCursor().bitmapData];
			xCursorData.data = xBitmapDatas;
			Mouse.registerCursor("xCursor",xCursorData);
			
			var upCursorData:MouseCursorData = new MouseCursorData();
			var upBitmapDatas:Vector.<BitmapData> = new <BitmapData>[new upCursor().bitmapData];
			upCursorData.data = upBitmapDatas;
			upCursorData.hotSpot = new Point(0,0);
			Mouse.registerCursor("upCursor",upCursorData);	
			
			var downCursorData:MouseCursorData = new MouseCursorData();
			var downBitmapDatas:Vector.<BitmapData> = new <BitmapData>[new downCursor().bitmapData];
			downCursorData.data = downBitmapDatas;
			downCursorData.hotSpot = new Point(0,31);
			Mouse.registerCursor("downCursor",downCursorData);	
			
			var leftCursorData:MouseCursorData = new MouseCursorData();
			var leftBitmapDatas:Vector.<BitmapData> = new <BitmapData>[new leftCursor().bitmapData];
			leftCursorData.data = leftBitmapDatas;
			Mouse.registerCursor("leftCursor",leftCursorData);	
			
			var rightCursorData:MouseCursorData = new MouseCursorData();
			var rightBitmapDatas:Vector.<BitmapData> = new <BitmapData>[new rightCursor().bitmapData];
			rightCursorData.data = rightBitmapDatas;
			rightCursorData.hotSpot = new Point(31,0);
			Mouse.registerCursor("rightCursor",rightCursorData);	
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function onPlay(event:MouseEvent):void{
			
			if(myTextField.text == "Enter the URL of a SOPA file"){
				return;
			}
			
			if(isPlaying){
				sopaStreamer.nSamplesDone = sopaStreamer.iSamplesPerChannel;
				
				if(isMotion){
					ns_front.pause();
					ns_right.pause();
					ns_back.pause();
					ns_left.pause();
					ns_bottom.pause();
					ns_top.pause();
				}
				
				isPlaying = false;
				iCountVideo = 0;
				
				myTextField.text = sopaURL;
				secondTextField.text ="Click to open dialog or";
				myTitle.text = "Thank you";
				messageField.text = "SopaAir version 1.0, Copyright 2016 AIST";
				playText.text = "Reload";
			}
			else{
				if(playText.text == " Play "){
					
					if(sopaStreamer.openSopaFile()){
						isPlaying = true;
						myTextField.text = sopaURL;
						messageField.text = "Please use stereo headphones.";
						playText.text = " Stop ";
						secondTextField.text = "Playing";
						timeIni = getTimer();
						timeElapsed = 0;
						/*						
						while(!sopaStreamer.isItRunning){
						timeElapsed = getTimer() - timeIni;
						if(timeElapsed > 10000)
						break;
						}	*/
						if(isMotion){
							ns_front.resume();
							ns_right.resume();
							ns_back.resume();
							ns_left.resume();
							ns_bottom.resume();
							ns_top.resume();
						}
						
						if(!stage.hasEventListener(Event.ENTER_FRAME))
							stage.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
					}
					else{
						isPlaying = false;	
						secondTextField.text = "Failed to load data!";
						messageField.text = "Failed to reproduce the SOPA file";
						playText.text = "Not ready";
					}	
				}
				else if(playText.text == "Reload" || playText.text == "Not ready"){
					sopaURL = myTextField.text;
					sopaStreamer.sopaURL = myTextField.text;
					sopaStreamer.nSamplesDone = 0;
					sopaStreamer.isReady = false;
					sopaStreamer.isFailed = false;
					sopaStreamer.sopaPrepare();
					
					var isReadyToPlay:Boolean = sopaStreamer.isPrepared;
					var isSopaFailed:Boolean = sopaStreamer.isFailed;
					while(!isReadyToPlay && !isSopaFailed && !sopaStreamer.isReady){
						var iLap:int = getTimer();
						isReadyToPlay = sopaStreamer.isPrepared;
						isSopaFailed = sopaStreamer.isFailed;
					}	
					if(sopaStreamer.isFailed){
						isPlaying = false;	
						secondTextField.text = "Failed to load data!";
						messageField.text = "Failed to reproduce the SOPA file";
						playText.text = "Not ready";
					}
					else{
						if(!view.scene.contains(planeFront)){
							// Build our Away3D 4 scene
							buildScene();					
						}
						secondTextField.text = "Please wait for a while";
						runVideo();
						createNativeCursor();
						
					}
				}
			}
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function check_key(e:MouseEvent):void 
		{
			if(sopaStreamer.isFocusOn){
				sopaStreamer.isFocusOn = false;
				sopaStreamer.isSharp = false;
				instText.text = " Turn on Cardioid ";
				infoText.textColor = 0x66ffcc;
				infoText.text = "Omnidirectional";
			}
			else{
				sopaStreamer.isFocusOn = true;
				sopaStreamer.isSharp = true;
				instText.text = "Turn off Cardioid";
				infoText.textColor = 0xff9900;
				infoText.text = "Cardioid";
			}
		}
		
		private function runVideo():void{
			if(!isPlaying){
				var tmpStr:String = sopaURL.substr(0,sopaURL.lastIndexOf("."));
				var urlStrFront:String = tmpStr +"0.flv";
				var urlStrRight:String = tmpStr +"1.flv";
				var urlStrBack:String = tmpStr +"2.flv";
				var urlStrLeft:String = tmpStr +"3.flv";
				var urlStrBottom:String = tmpStr +"4.flv";
				var urlStrTop:String = tmpStr +"5.flv";
				
				ns_front.play(urlStrFront);
				ns_front.pause();
				ns_right.play(urlStrRight);
				ns_right.pause();
				ns_back.play(urlStrBack);
				ns_back.pause();
				ns_left.play(urlStrLeft);
				ns_left.pause();
				ns_bottom.play(urlStrBottom);
				ns_bottom.pause();
				ns_top.play(urlStrTop);
				ns_top.pause();
				
				if(!stage.hasEventListener(Event.ENTER_FRAME))
					stage.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
			}
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		private function setupAway3D():void
		{
			// Init Away3D
			view = new View3D;
			view.backgroundColor = 0xffff33;
			view.y = 0;
			view.x = 0;
			view.width = WIDTH;
			view.height = HEIGHT;
			addChild(view);
			
			//setup the camera
			view.camera.z = -256;
			view.camera.y = 0;
			view.camera.x = 0;
			view.camera.lookAt(new Vector3D());
			view.camera.lens = new PerspectiveLens(90);
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		private function setupVideoMaterial():void
		{
			/* GUIDE:
			On each enter frame we are going to update bitmap which is used for the material/texture on the mesh (planeMesh)
			1. Build a video player
			2. Grab BitmapData of the video player on enterframe and update the TextureMaterial
			*/
			
			// Setup video
			video_front = new Video(videoW,videoH);
			video_right = new Video(videoW,videoH);
			video_back = new Video(videoW,videoH);
			video_left = new Video(videoW,videoH);
			video_bottom = new Video(videoW,videoH);
			video_top = new Video(videoW,videoH);
			
			// For front plane
			nc_front = new NetConnection();
			nc_front.addEventListener(NetStatusEvent.NET_STATUS, frontHandler);
			nc_front.connect(null);
			
			videoContainer_front = new Sprite();
			videoContainer_front.addChild(video_front);
			
			// For right plane
			nc_right = new NetConnection();
			nc_right.addEventListener(NetStatusEvent.NET_STATUS, rightHandler);
			nc_right.connect(null);
			
			videoContainer_right = new Sprite();
			videoContainer_right.addChild(video_right);
			
			// For back plane
			nc_back = new NetConnection();
			nc_back.addEventListener(NetStatusEvent.NET_STATUS, backHandler);
			nc_back.connect(null);
			
			videoContainer_back = new Sprite();
			videoContainer_back.addChild(video_back);
			
			// For left plane
			nc_left = new NetConnection();
			nc_left.addEventListener(NetStatusEvent.NET_STATUS, leftHandler);
			nc_left.connect(null);
			
			videoContainer_left = new Sprite();
			videoContainer_left.addChild(video_left);
			
			// For bottom plane
			nc_bottom = new NetConnection();
			nc_bottom.addEventListener(NetStatusEvent.NET_STATUS, bottomHandler);
			nc_bottom.connect(null);
			
			videoContainer_bottom = new Sprite();
			videoContainer_bottom.addChild(video_bottom);	
			
			// For top plane
			nc_top = new NetConnection();
			nc_top.addEventListener(NetStatusEvent.NET_STATUS, topHandler);
			nc_top.connect(null);
			
			videoContainer_top = new Sprite();
			videoContainer_top.addChild(video_top);	
			
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function frontHandler(e:NetStatusEvent):void{
			if(e.info.code == "NetConnection.Connect.Success"){
				ns_front = new NetStream(nc_front);
				var client:Object = new Object( );
				client.onMetaData = function(o:Object):void {};
				client.onCuePoint = function(o:Object):void {};
				ns_front.client = client;
				ns_front.addEventListener(NetStatusEvent.NET_STATUS, statusChanged);
				
				video_front.attachNetStream(ns_front);
			}
			else{
				secondTextField.text = "NetConnection failed!";
				iCountVideo = 0;
			}
			
			nc_front.removeEventListener(NetStatusEvent.NET_STATUS, frontHandler);
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function rightHandler(e:NetStatusEvent):void{
			if(e.info.code == "NetConnection.Connect.Success"){
				ns_right = new NetStream(nc_right);
				
				var client:Object = new Object( );
				client.onMetaData = function(o:Object):void {};
				client.onCuePoint = function(o:Object):void {};
				ns_right.client = client;
				ns_right.addEventListener(NetStatusEvent.NET_STATUS, statusChanged);					
				
				video_right.attachNetStream(ns_right);
			}
			else{
				secondTextField.text = "NetConnection failed!";
				iCountVideo = 0;
			}
			
			nc_right.removeEventListener(NetStatusEvent.NET_STATUS, rightHandler);
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function backHandler(e:NetStatusEvent):void{
			if(e.info.code == "NetConnection.Connect.Success"){
				ns_back = new NetStream(nc_back);
				
				var client:Object = new Object( );
				client.onMetaData = function(o:Object):void {};
				client.onCuePoint = function(o:Object):void {};
				ns_back.client = client;
				ns_back.addEventListener(NetStatusEvent.NET_STATUS, statusChanged);					
				
				video_back.attachNetStream(ns_back);
			}
			else{
				secondTextField.text = "NetConnection failed!";
				iCountVideo = 0;
			}
			
			nc_back.removeEventListener(NetStatusEvent.NET_STATUS, backHandler);
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function leftHandler(e:NetStatusEvent):void{
			if(e.info.code == "NetConnection.Connect.Success"){
				ns_left = new NetStream(nc_left);
				
				var client:Object = new Object( );
				client.onMetaData = function(o:Object):void {};
				client.onCuePoint = function(o:Object):void {};
				ns_left.client = client;
				ns_left.addEventListener(NetStatusEvent.NET_STATUS, statusChanged);					
				
				video_left.attachNetStream(ns_left);
			}
			else{
				secondTextField.text = "NetConnection failed!";
				iCountVideo = 0;
			}
			
			nc_left.removeEventListener(NetStatusEvent.NET_STATUS, leftHandler);
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function bottomHandler(e:NetStatusEvent):void{
			if(e.info.code == "NetConnection.Connect.Success"){
				ns_bottom = new NetStream(nc_bottom);
				
				var client:Object = new Object( );
				client.onMetaData = function(o:Object):void {};
				client.onCuePoint = function(o:Object):void {};
				ns_bottom.client = client;
				ns_bottom.addEventListener(NetStatusEvent.NET_STATUS, statusChanged);					
				
				video_bottom.attachNetStream(ns_bottom);
			}
			else{
				secondTextField.text = "NetConnection failed!";
				iCountVideo = 0;
			}
			
			nc_bottom.removeEventListener(NetStatusEvent.NET_STATUS, bottomHandler);
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function topHandler(e:NetStatusEvent):void{
			if(e.info.code == "NetConnection.Connect.Success"){
				ns_top = new NetStream(nc_top);
				
				var client:Object = new Object( );
				client.onMetaData = function(o:Object):void {};
				client.onCuePoint = function(o:Object):void {};
				ns_top.client = client;
				ns_top.addEventListener(NetStatusEvent.NET_STATUS, statusChanged);					
				
				video_top.attachNetStream(ns_top);				
			}
			else{
				secondTextField.text = "NetConnection failed!";
				iCountVideo = 0;
			}
			nc_top.removeEventListener(NetStatusEvent.NET_STATUS, topHandler);
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function statusChanged(e:NetStatusEvent):void{
			if(e.info.code == "NetStream.Play.Start"){
				iCountVideo ++;
				if(iCountVideo == PLANE_NUM){
					isMotion = true;
					if(secondTextField.text == "Please wait for a while"){
						messageField.text = "Succeeded to load data";
						myTitle.text = "Panoramic sound player";
						secondTextField.text = "Ready to play";
						playText.text = " Play ";
					}
					else{
						if(sopaStreamer.openSopaFile()){
							isPlaying = true;
							ns_front.resume();
							ns_right.resume();
							ns_back.resume();
							ns_left.resume();
							ns_bottom.resume();
							ns_top.resume();
							secondTextField.text = "Playing";
							myTextField.text = sopaURL;
							messageField.text = "Please use stereo headphones.";
							playText.text = " Stop ";
							timeIni = getTimer();
							timeElapsed = 0;
						}
						else{
							isPlaying = false;	
							myTextField.text = sopaURL;
							secondTextField.text = "Click to open dialogbox or";
							messageField.text = "Failed to reproduce the SOPA file";
							playText.text = "Not ready";
						}
					}
				}
			}
			else if(e.info.code == "NetStream.Play.StreamNotFound"){
				if(myTextField.text != "- Video not found -"){
					myTextField.text = "- Video not found -";
					if(isMotion){
						isMotion = false;
					}
					if(view.scene.contains(planeFront))
						view.scene.removeChild(planeFront);
					if(view.scene.contains(planeRight))
						view.scene.removeChild(planeRight);
					if(view.scene.contains(planeBack))
						view.scene.removeChild(planeBack);
					if(view.scene.contains(planeLeft))
						view.scene.removeChild(planeLeft);
					if(view.scene.contains(planeBottom))
						view.scene.removeChild(planeBottom);
					if(view.scene.contains(planeTop))
						view.scene.removeChild(planeTop);
					
					/**** LOAD PNG ****/
					isPngOK = false;
					var tmpStr:String = sopaURL.substr(0,sopaURL.lastIndexOf("."));
					var pngStr:String = tmpStr + ".png";
					var myLoader:Loader = new Loader();
					myLoader.load(new URLRequest(pngStr));
					myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);				
					myLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onIOerror);
					
				}
			}
			else if(e.info.code == "NetStream.Play.Stop"){
				iCountVideo --;
				if(iCountVideo == 0){
					isPlaying = false;
					myTextField.text = sopaURL;
					secondTextField.text ="Click to open dialog or";
					myTitle.text = "Thank you";
					myTitle.alpha = 1;
					messageField.text = "SopaAir version 1.0, Copyright 2016 AIST";
					playText.text = "Reload";
				}
			}
		}
		
		/************************************************************************
		 * 					Error detected in data transmission					*
		 ************************************************************************/		
		
		private function onIOerror(event:IOErrorEvent):void{
			var loader:Loader = new Loader();
			var defStr:String = ".jpg";
			
			removeEventListener(Event.COMPLETE, completeHandler);
			removeEventListener(IOErrorEvent.IO_ERROR, onIOerror);
			
			if(isDefault){
				/**** LOAD Default PNG ****/
				isPngOK = false;
				isDefault = false;
				myTextField.text = sopaURL;
				defaultImage();
			}
			else if(!isPngOK){
				loader = new Loader();
				
				var tmpStr:String = sopaURL.substr(0,sopaURL.lastIndexOf("."));
				var pngStr:String = tmpStr + defStr;
				
				isDefault = true;
				loader.load(new URLRequest(pngStr),new LoaderContext(true));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);			
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOerror);
			}
		}
		
		/************************************************************************
		 * 							Setup Skybox								*
		 ***********************************************************************/
		
		private function defaultImage():void{
			var bmd0:BitmapData = new embeddedImage().bitmapData;
			var sourceRect:Rectangle;
			var destPoint:Point = new Point(0,0);
			var myPosX:BitmapData = new BitmapData(512,512);
			var myNegX:BitmapData = new BitmapData(512,512);
			var myPosY:BitmapData = new BitmapData(512,512);
			var myNegY:BitmapData = new BitmapData(512,512);
			var myPosZ:BitmapData = new BitmapData(512,512);
			var myNegZ:BitmapData = new BitmapData(512,512);
			var tmpStr:String = "default_cube";
			var pngStr:String;
			
			pngStr = tmpStr + ".png"
/*			
			myTextField.filters = [new DropShadowFilter()];
			myTextField.textColor = 0xffff99;
			myTextField.text = pngStr + " is loaded";
			myTextField.x = Math.max((stage.stageWidth - myTextField.width) / 2,0);	*/
			
			sourceRect = new Rectangle(512,0,512,512);
			myPosX.copyPixels(bmd0,sourceRect,destPoint);
			sourceRect = new Rectangle(1536,0,512,512);
			myNegX.copyPixels(bmd0,sourceRect,destPoint);
			sourceRect = new Rectangle(512,512,512,512);
			myPosY.copyPixels(bmd0,sourceRect,destPoint);
			sourceRect = new Rectangle(0,512,512,512);
			myNegY.copyPixels(bmd0,sourceRect,destPoint);
			sourceRect = new Rectangle(0,0,512,512);
			myPosZ.copyPixels(bmd0,sourceRect,destPoint);
			sourceRect = new Rectangle(1024,0,512,512);
			myNegZ.copyPixels(bmd0,sourceRect,destPoint);
			
			if(skyBox)
				skyBox.dispose();
			//setup the skybox texture
			var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture(myPosX,
				myNegX,
				myPosY,
				myNegY,
				myPosZ,
				myNegZ);
			
			skyBox = new SkyBox(cubeTexture);
			view.scene.addChild(skyBox);
			
			removeEventListener(Event.COMPLETE, completeHandler);
			removeEventListener(IOErrorEvent.IO_ERROR, onIOerror);
			
			myTitle.text = "Panoramic image with panoramic audio";
			secondTextField.text = "Image not found";
			playText.text = " Play ";
		}
		
		private function completeHandler(event:Event):void{			
			var bmd0:BitmapData = Bitmap(LoaderInfo(event.target).content).bitmapData;
			var sourceRect:Rectangle;
			var destPoint:Point = new Point(0,0);
			var myPosX:BitmapData = new BitmapData(512,512);
			var myNegX:BitmapData = new BitmapData(512,512);
			var myPosY:BitmapData = new BitmapData(512,512);
			var myNegY:BitmapData = new BitmapData(512,512);
			var myPosZ:BitmapData = new BitmapData(512,512);
			var myNegZ:BitmapData = new BitmapData(512,512);
			var tmpStr:String = sopaURL.substr(0,sopaURL.lastIndexOf("."));
			var pngStr:String;
			
			if(isDefault)
				pngStr = tmpStr + ".jpg";
			else
				pngStr = tmpStr + ".png"
			
			myTextField.filters = [new DropShadowFilter()];
			myTextField.textColor = 0xffff99;
			myTextField.text = pngStr + " is loaded";
			myTextField.x = Math.max((stage.stageWidth - myTextField.width) / 2,0);
			
			sourceRect = new Rectangle(512,0,512,512);
			myPosX.copyPixels(bmd0,sourceRect,destPoint);
			sourceRect = new Rectangle(1536,0,512,512);
			myNegX.copyPixels(bmd0,sourceRect,destPoint);
			sourceRect = new Rectangle(512,512,512,512);
			myPosY.copyPixels(bmd0,sourceRect,destPoint);
			sourceRect = new Rectangle(0,512,512,512);
			myNegY.copyPixels(bmd0,sourceRect,destPoint);
			sourceRect = new Rectangle(0,0,512,512);
			myPosZ.copyPixels(bmd0,sourceRect,destPoint);
			sourceRect = new Rectangle(1024,0,512,512);
			myNegZ.copyPixels(bmd0,sourceRect,destPoint);
			
			if(skyBox)
				skyBox.dispose();
			//setup the skybox texture
			var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture(myPosX,
				myNegX,
				myPosY,
				myNegY,
				myPosZ,
				myNegZ);
			
			skyBox = new SkyBox(cubeTexture);
			view.scene.addChild(skyBox);
			
			removeEventListener(Event.COMPLETE, completeHandler);
			removeEventListener(IOErrorEvent.IO_ERROR, onIOerror);
			
			isPngOK = true;	
			isDefault = false;
			myTitle.text = "Panoramic image with panoramic audio";
			secondTextField.text = "Ready to play";
			playText.text = " Play ";
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		private function buildScene():void
		{
			// Var ini
			bmpDataFront = new BitmapData(videoW,videoH);
			bmpDataRight = new BitmapData(videoW,videoH);
			bmpDataBack = new BitmapData(videoW,videoH);
			bmpDataLeft = new BitmapData(videoW,videoH);
			bmpDataBottom = new BitmapData(videoW,videoH);
			bmpDataTop = new BitmapData(videoW,videoH);
			
			planeGeom = new PlaneGeometry(videoW,videoH);
			planeFront = new Mesh(planeGeom,new ColorMaterial(Math.random()*0xFFFFFF));
			planeFront.rotationX = -90;
			view.scene.addChild(planeFront);
			
			planeRight = new Mesh(planeGeom,new ColorMaterial(Math.random()*0xFFFFFF));
			planeRight.rotationX = -90;
			planeRight.rotationY = 90;
			planeRight.x = videoW / 2;
			planeRight.z = -videoW / 2;
			view.scene.addChild(planeRight);
			
			planeBack = new Mesh(planeGeom,new ColorMaterial(Math.random()*0xFFFFFF));
			planeBack.rotationX = -90;
			planeBack.rotationY = 180;
			planeBack.z = -videoW;
			view.scene.addChild(planeBack);
			
			planeLeft = new Mesh(planeGeom,new ColorMaterial(Math.random()*0xFFFFFF));
			planeLeft.rotationX = -90;
			planeLeft.rotationY = 270;
			planeLeft.x = -videoW / 2;
			planeLeft.z = -videoW / 2;
			view.scene.addChild(planeLeft);
			
			planeBottom = new Mesh(planeGeom,new ColorMaterial(Math.random()*0xFFFFFF));
			planeBottom.rotationX = 0;
			planeBottom.y = -videoH / 2;
			planeBottom.z = -videoW / 2;
			view.scene.addChild(planeBottom);	
			
			planeTop = new Mesh(planeGeom,new ColorMaterial(Math.random()*0xFFFFFF));
			planeTop.rotationX = 180;
			planeTop.y = videoH / 2;
			planeTop.z = -videoW / 2;
			view.scene.addChild(planeTop);	
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		private function mouseLeft(event:MouseEvent):void{
			isOut = true;
			Mouse.cursor = MouseCursor.AUTO;
			/*			
			if(iCountVideo == 0)
			stage.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);	*/
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		private function mouseIn(event:MouseEvent):void{
			isOut = false;
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		private function updatePlaneTextureUsingVideo():void
		{
			// Draw!
			bmpDataFront.draw(videoContainer_front);
			if(!bmpTextureFront)
				bmpTextureFront = new BitmapTexture(bmpDataFront);
			else{
				bmpTextureFront.dispose();
				bmpTextureFront = new BitmapTexture(bmpDataFront);
			}
			
			bmpDataRight.draw(videoContainer_right);
			if(!bmpTextureRight)
				bmpTextureRight = new BitmapTexture(bmpDataRight);
			else{
				bmpTextureRight.dispose();
				bmpTextureRight = new BitmapTexture(bmpDataRight);
			}
			
			bmpDataBack.draw(videoContainer_back);
			if(!bmpTextureBack)
				bmpTextureBack = new BitmapTexture(bmpDataBack);
			else{
				bmpTextureBack.dispose();
				bmpTextureBack = new BitmapTexture(bmpDataBack);
			}
			
			bmpDataLeft.draw(videoContainer_left);
			if(!bmpTextureLeft)
				bmpTextureLeft = new BitmapTexture(bmpDataLeft);
			else{
				bmpTextureLeft.dispose();
				bmpTextureLeft = new BitmapTexture(bmpDataLeft);
			}
			
			bmpDataBottom.draw(videoContainer_bottom);
			if(!bmpTextureBottom)
				bmpTextureBottom = new BitmapTexture(bmpDataBottom);
			else{
				bmpTextureBottom.dispose();
				bmpTextureBottom = new BitmapTexture(bmpDataBottom);
			}	
			
			bmpDataTop.draw(videoContainer_top);
			if(!bmpTextureTop)
				bmpTextureTop = new BitmapTexture(bmpDataTop);
			else{
				bmpTextureTop.dispose();
				bmpTextureTop = new BitmapTexture(bmpDataTop);
			}	
			
			// Set texture
			if(!planeTextureFront)
				planeTextureFront = new TextureMaterial(bmpTextureFront,false,false,true);
			else
				planeTextureFront.texture = bmpTextureFront;
			planeFront.material = planeTextureFront;
			
			if(!planeTextureRight)
				planeTextureRight = new TextureMaterial(bmpTextureRight,false,false,true);
			else
				planeTextureRight.texture = bmpTextureRight;
			planeRight.material = planeTextureRight;
			
			if(!planeTextureBack)
				planeTextureBack = new TextureMaterial(bmpTextureBack,false,false,true);
			else
				planeTextureBack.texture = bmpTextureBack;
			planeBack.material = planeTextureBack;
			
			if(!planeTextureLeft)
				planeTextureLeft = new TextureMaterial(bmpTextureLeft,false,false,true);
			else
				planeTextureLeft.texture = bmpTextureLeft;
			planeLeft.material = planeTextureLeft;
			
			if(!planeTextureBottom)
				planeTextureBottom = new TextureMaterial(bmpTextureBottom,false,false,true);
			else
				planeTextureBottom.texture = bmpTextureBottom;
			planeBottom.material = planeTextureBottom;	
			
			if(!planeTextureTop)
				planeTextureTop = new TextureMaterial(bmpTextureTop,false,false,true);
			else
				planeTextureTop.texture = bmpTextureTop;
			planeTop.material = planeTextureTop;	
		}
		
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		private function initEventListeners():void
		{			
			// Enter frame handler
			stage.addEventListener(MouseEvent.MOUSE_OUT,mouseLeft);
			stage.addEventListener(MouseEvent.MOUSE_OVER,mouseIn);
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		private function enterFrameHandler(e:Event=null):void
		{
			var nPan:Number;
			var nTilt:Number;
			var nPosX:Number = view.mouseX - view.width / 2;
			var nPosY:Number = view.mouseY - view.height / 2;
			
			if(sopaStreamer.isFailed){
				isPlaying = false;
				secondTextField.text ="Click to open dialog or";
				messageField.text = "Failed to reproduce the SOPA file";
				playText.text = "Not ready";
				return;
			}
			if(isPlaying){
				if(timeElapsed < 8192){
					myTitle.alpha = (8192 - timeElapsed) / 8192;
					timeElapsed = getTimer() - timeIni;
					if(timeElapsed >= 8192){
						myTitle.text = "Move the mouse pointer to control panning.";
					}
				}
				if(sopaStreamer.isFinished){
					if(!isMotion){					
						isPlaying = false;
						myTextField.text = sopaURL;
						secondTextField.text ="Click to open dialog or";
						myTitle.text = "Thank you";
						myTitle.alpha = 1;
						playText.text = "Reload";
					}
				}
			}
			
			if(isMotion)
				updatePlaneTextureUsingVideo();
			
			if(view.mouseX > myTextField.x && view.mouseX < myTextField.x + myTextField.width
				&& view.mouseY > myTextField.y && view.mouseY < myTextField.y + myTextField.height){
				nPan = nTilt = 0;
			}
				
			else if(!isOut){
				if(Math.abs(nPosX) > nThresholdX){
					if(nPosX > 0){
						nPan = (nPosX - nThresholdX) * SENS / nThresholdX;
						Mouse.cursor = "rightCursor";
					}
					else{
						nPan = (nThresholdX + nPosX) * SENS / nThresholdX;
						Mouse.cursor = "leftCursor";
					}
				}
				else
					nPan = 0;
				
				if(Math.abs(nPosY) > nThresholdY){
					if(nPosY > 0){
						nTilt = (nPosY - nThresholdY) * SENS / nThresholdY;
						Mouse.cursor = "downCursor";
					}
					else{
						nTilt = (nThresholdY + nPosY) * SENS / nThresholdY;						
						Mouse.cursor = "upCursor";
					}
				}
				else
					nTilt = 0;
				
				if(nPan == 0 && nTilt == 0)
					Mouse.cursor = MouseCursor.HAND;
				
				if(Math.abs(nPan) < SENS && Math.abs(nTilt) < SENS){
					horizontalAngle -= nPan * Math.PI / 180.0;
					verticalAngle += nTilt * Math.PI / 180;
					if(verticalAngle > Math.PI / 4){
						verticalAngle = Math.PI / 4;
						nTilt = 0;
						Mouse.cursor = "xCursor";
					}
					else if(verticalAngle < -Math.PI / 4){
						verticalAngle = -Math.PI / 4;
						nTilt = 0;
						Mouse.cursor = "xCursor";
					}
					while(horizontalAngle > Math.PI)
						horizontalAngle -= 2 * Math.PI;
					while(horizontalAngle <= -Math.PI)
						horizontalAngle += Math.PI * 2;					
					
					view.camera.rotationY += nPan;
					view.camera.rotationX += nTilt;
				}
				var nDir:Number = horizontalAngle * 36 / Math.PI;
				nDir += 36;
				var iHori:int = nDir;
				nDir = verticalAngle * 36 / Math.PI;
				nDir += 18;
				var iVert:int = nDir;
				sopaStreamer.horizontalAngle = iHori;
				sopaStreamer.verticalAngle = iVert;	
				
			}	
			
			view.render();
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
	}
	// -------------------------------------------------------------------------------------------------------------------------------
}