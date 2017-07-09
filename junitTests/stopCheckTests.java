import org.junit.*;
import static org.junit.Assert.assertEquals;

import org.nlogo.headless.HeadlessWorkspace;
import org.nlogo.api.Dump;
import org.nlogo.util.Utils;
import org.nlogo.core.*;

public class stopCheckTests {

	//instantiate the headless workspace 
	public HeadlessWorkspace ws;

	@Before
	public void setup(){
		//runs before the test, here it opens the example file with Netlogo Code
		ws = HeadlessWorkspace.newInstance();
		try {
			ws.open("../NLCode.nlogo");
			ws.setDimensions(new WorldDimensions(0, 0, 0, 0, 12.0, false, true));
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
	}

	@After
	public void tearDown(){
		//runs after the test, gets rid of the workspace
		try {
			ws.dispose();
		}
		catch(Exception ex){
			ex.printStackTrace();
		}
	}

	@Test
	public void testAdd() {
		String str = "Junit is working fine";
		assertEquals("Junit is working fine",str);
	}
	@Test
	public void stopCheck1(){
		ws.command("setup");
		ws.command("ask patches[ set FO -1 ]");
		ws.command("go");
	}
	@Test
	public void stopCheck2(){
		ws.command("setup");
		ws.command("set flowDist 2");
		ws.command("go");
	}
//Will not work on slower computers. uncomment at your own risk.
/*	@Test
	public void stopCheck3(){
		ws.command("set initNumBifidos 2000000");
		ws.command("setup");
		ws.command("go");
	}/**/
	@Test
	public void stopCheck4(){
		ws.command("setup");
		ws.clearTurtles();
		ws.command("go");
	}

}
