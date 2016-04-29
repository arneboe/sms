import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import android.content.IntentFilter;
import android.os.Bundle;
import android.telephony.gsm.SmsMessage;
import java.net.*;
import java.io.BufferedWriter;
import java.io.OutputStreamWriter;
import java.util.concurrent.LinkedBlockingQueue;


final int SERVERPORT = 12345;
final String SERVER_IP = "192.168.0.15";
final String SPLITTER = "DASISTEINTOLLERGEHEIMERSPLITTERDENNIEMANDKENNT";


String message = ""; 
String number = ""; 
SmsReceiver mySMSReceiver = new SmsReceiver();

public class Sms
{
  public String message;
  public String number;
}

LinkedBlockingQueue<Sms> queue = new LinkedBlockingQueue<Sms>();

@Override
public void onCreate(Bundle savedInstanceState) 
{
  super.onCreate(savedInstanceState);
  getActivity().getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON); //keep screen on
  IntentFilter filter = new IntentFilter("android.provider.Telephony.SMS_RECEIVED");   
  getActivity().registerReceiver(mySMSReceiver, filter); // launch class when SMS are RECEIVED
}

void setup()
{
   size(400,600);
}

 
void draw()
{
  if(queue.size() > 0)
  {
    try 
    {
        InetAddress serverAddr = InetAddress.getByName(SERVER_IP);
        Socket socket = new Socket(serverAddr, SERVERPORT);
        PrintWriter out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(socket.getOutputStream())), true);
        Sms sms = queue.poll();
        out.println(sms.number + SPLITTER + sms.message);
        out.flush();
        delay(100);
        out.close();
    } 
    catch (Exception e)
    {
      fill(0,0,0);
      rect(0,0,400,600);
      fill(255,0,0);
      text(e.getMessage(),10,40);
    }
  }
}
 
public class SmsReceiver extends BroadcastReceiver //Class to get SMS
{
  @Override
  public void onReceive(Context context, Intent intent) 
  {
      //get the SMS message passed in
      Bundle bundle = intent.getExtras();        
      SmsMessage[] msgs = null;
      String caller="";
      String str="";
                
      if (bundle != null)
      {
          //retrieve the SMS message received
          Object[] pdus = (Object[]) bundle.get("pdus");
          msgs = new SmsMessage[pdus.length];            
          for (int i=0; i<msgs.length; i++){
              msgs[i] = SmsMessage.createFromPdu((byte[])pdus[i]);                
              caller += msgs[i].getOriginatingAddress();
              str += msgs[i].getMessageBody().toString();
          } 
      }   
      Sms sms = new Sms();
      sms.message = str;
      sms.number = caller;
      try
      {
        queue.put(sms);
      }
      catch(InterruptedException ex)
      {}
  }
}