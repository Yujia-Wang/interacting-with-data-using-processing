import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.utils.*;

UnfoldingMap map;
AbstractMapProvider provider1;
AbstractMapProvider provider2;
color marker_color = color(139, 0, 139, 100);
color marker_color_over = color(255, 0, 0, 150);
color text_color = color(0, 0, 0);
int clickX = 0;
int clickY = 0;
ArrayList<TweetInfo> tweetInfo_list = new ArrayList<TweetInfo>();

class TweetInfo {
  String Tweet_text;
  long User_id;
  String User_name;
  String Created_time;
  float Tweet_lon;
  float Tweet_lat;
  
  TweetInfo(String text, long id, String name, String time, float lon, float lat) {
    Tweet_text = text;
    User_id = id;
    User_name = name;
    Created_time = time;
    Tweet_lon = lon;
    Tweet_lat = lat; 
  }
  
  void paint_tweet() {
    Location location;
    location = new Location(Tweet_lat, Tweet_lon); 
    SimplePointMarker marker = new SimplePointMarker(location); 
    ScreenPosition pos = marker.getScreenPosition(map);
    
    if (mousePressed) {
      if (clickX <= (pos.x + 15) && clickX >= (pos.x - 15) && clickY <= (pos.y + 15) && clickY >= (pos.y - 15)) {
        strokeWeight(10);
        stroke(marker_color_over);
        strokeCap(SQUARE);
        noFill();
        arc(pos.x, pos.y, 34, 34, -PI * 0.9, -PI * 0.1);
        arc(pos.x, pos.y, 34, 34, PI * 0.1, PI * 0.9);
        
        strokeWeight(4);
        strokeCap(SQUARE);
        noFill();
        rect(pos.x + 30, pos.y - 100, 400, 200, 7);
        
        fill(text_color);
        textSize(13);
        textAlign(LEFT);
        text("User Name: " + User_name, pos.x + 35, pos.y - 80);
        text("User ID: " + User_id, pos.x + 35, pos.y - 60);
        text("Created at: " + Created_time, pos.x + 35, pos.y - 40);
        text(Tweet_text, pos.x + 35, pos.y - 20, 350, 200);
      }
      else {
        strokeWeight(10);
        stroke(marker_color);
        strokeCap(SQUARE);
        noFill(); 
        arc(pos.x, pos.y, 34, 34, -PI * 0.9, -PI * 0.1);
        arc(pos.x, pos.y, 34, 34, PI * 0.1, PI * 0.9);
      }
    }
    else {
      if (mouseX <= (pos.x + 15) && mouseX >= (pos.x - 15) && mouseY <= (pos.y + 15) && mouseY >= (pos.y - 15)) {
        strokeWeight(10);
        stroke(marker_color_over);
        strokeCap(SQUARE);
        noFill();
        arc(pos.x, pos.y, 34, 34, -PI * 0.9, -PI * 0.1);
        arc(pos.x, pos.y, 34, 34, PI * 0.1, PI * 0.9);
        
        fill(text_color);
        textSize(13);
        textAlign(LEFT);
        text(Tweet_text, pos.x + 15, pos.y + 15, 300, 300);
      }
      else {
        strokeWeight(10);
        stroke(marker_color);
        strokeCap(SQUARE);
        noFill(); 
        arc(pos.x, pos.y, 34, 34, -PI * 0.9, -PI * 0.1);
        arc(pos.x, pos.y, 34, 34, PI * 0.1, PI * 0.9);
      }
    }
  }  
}

void setup() {
  size(800, 600, P2D);  
  
  provider1 = new Microsoft.RoadProvider();
  provider2 = new Microsoft.AerialProvider();
  
  map = new UnfoldingMap(this, provider1); 

  MapUtils.createDefaultEventDispatcher(this, map);  
 
  read_data();
}

void draw() {
  map.draw();
  for (int i = 0; i < tweetInfo_list.size(); i++) {
    tweetInfo_list.get(i).paint_tweet();
  } 
}

void mousePressed() {
  clickX = mouseX;
  clickY = mouseY;
}

void keyPressed() {
  if (key == '1') {
    map.mapDisplay.setProvider(provider1);
    marker_color = color(139, 0, 139, 100);
    marker_color_over = color(255, 0, 0, 150);
    text_color = color(0, 0, 0);
  } 
  else if (key == '2') {
    map.mapDisplay.setProvider(provider2);
    marker_color = color(255, 255, 0, 150);
    marker_color_over = color(0, 255, 255, 150);
    text_color = color(255, 255, 255);
  }
}

void read_data() {
  String tweet_text;
  long user_id;
  String user_name;
  String created_time;
  float tweet_lon;
  float tweet_lat;
  JSONObject tweet;
  JSONArray coordinates;
  
  JSONArray tweets = loadJSONArray("tweets.json");
  for (int i = 0; i < tweets.size(); i++) {
    tweet = tweets.getJSONObject(i);
    
    // Text
    tweet_text = tweet.getString("text");
    
    // User id
    JSONObject userid = tweet.getJSONObject("user");
    user_id = userid.getLong("id");
    
    // User name
    JSONObject username = tweet.getJSONObject("user");
    user_name = username.getString("name");
    
    // Created time
    created_time = tweet.getString("created_at");
    
    // Coordinates
    if (tweet.get("coordinates").toString() == "null") {
      if (tweet.get("place").toString() == "null") {
        continue;
      }
      else {
        JSONObject place = tweet.getJSONObject("place");
        JSONObject bounding_box = place.getJSONObject("bounding_box");
        JSONArray coordinates_tmp_array = bounding_box.getJSONArray("coordinates");
        coordinates = coordinates_tmp_array.getJSONArray(0);
        coordinates = coordinates.getJSONArray(0);
        tweet_lon = coordinates.getFloat(0);
        tweet_lat = coordinates.getFloat(1);
      }
    }
    else {
      JSONObject coordinates_tmp_object = tweet.getJSONObject("coordinates");
      coordinates = coordinates_tmp_object.getJSONArray("coordinates");
      tweet_lon = coordinates.getFloat(0);
      tweet_lat = coordinates.getFloat(1);
    }
    
    TweetInfo tweetInfo = new TweetInfo(tweet_text, user_id, user_name, created_time, tweet_lon, tweet_lat);
    tweetInfo_list.add(tweetInfo);
  }
}