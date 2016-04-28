import processing.net.*;
import java.util.HashMap;
import java.util.List;
import java.util.LinkedList;
import java.util.Arrays;
import java.util.Random;

Server s;
Random rand = new Random();
final String SPLITTER = "DASISTEINTOLLERGEHEIMERSPLITTERDENNIEMANDKENNT";
int outOfNamesI = 1;
List<String> nameList = new LinkedList<String>(
                          Arrays.asList("Sweetheart87",
                                        "sirloafalot",
                                        "vanman33",
                                        "pfag",
                                        "yourbiggestfan",
                                        "cutethulhu"));


HashMap<String, String> names = new HashMap<String, String>();

public class Sms
{
  public String message;
  public String name;
}

LinkedList<Sms> messages = new LinkedList<Sms>();

void setup() { 
  fullScreen();
  background(0);
  stroke(0, 255, 0);
  frameRate(30); // Slow it down a little
  s = new Server(this, 12345);  // Start a simple server on a port
} 

void draw() { 

  
  // Receive data from client
  Client c = s.available();
  if (c != null) {
    while(c.available() <= 0);//wait till data is available
    final String input = c.readString(); 
    if(!input.isEmpty())
    {
      String[] arr = input.split(SPLITTER);
      if(arr.length != 2)
      {
        System.out.println("input: " + input);
        System.out.println("split ERROR");
        return;
      }
      final String number = arr[0];
      final String msg = arr[1];
      postMessage(number, msg);
    }
    else
    {
      System.out.println("input empty ERROR");
    }
  }
  
  drawMessages();
}

void postMessage(final String number, final String msg)
{
  final String nickname = getNickname(number);
  System.out.println(nickname + "(" + number + "): " + msg);
  Sms sms = new Sms();
  sms.name = nickname;
  sms.message = msg;
  messages.add(sms);
}

String getNickname(final String number)
{
  if(!names.containsKey(number))
  {
    String nickName = "";
    if(nameList.isEmpty())
    {
      nickName = "out_of_names" + outOfNamesI;
      outOfNamesI++;
    }
    else
    {
      final int i = rand.nextInt(nameList.size());
      nickName = nameList.get(i);
      nameList.remove(i);
    }
    names.put(number, nickName);
  }
  return names.get(number);
}

void drawMessages()
{
  background(0);
  fill(0, 255, 0);
  textSize(50);
  text("Send", 20, 60);
  line(0, 120, width, 120);
  int y = height - 40;
  for(int i = messages.size() - 1; i >= 0; --i)
  {
    Sms sms = messages.get(i);
    final String txt = sms.name + ": " + sms.message;
    int size = 20;
    textSize(size);
    while(textWidth(txt) > width - 10)
    {
      --size;
      textSize(size);
    }
    if(size <= 10) 
      textSize(10);
    text(txt, 10, y);
    y -= 28;
    if(y <= 120) break;
  }
}

void keyPressed() {
  exit();
}