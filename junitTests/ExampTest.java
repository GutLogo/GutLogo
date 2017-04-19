import org.junit.*;
import static org.junit.Assert.assertEquals;

import org.nlogo.headless.HeadlessWorkspace;
import org.nlogo.api.Dump;
import org.nlogo.util.Utils;

public class ExampTest {

	//instantiate the headless workspace 
	public HeadlessWorkspace ws;

	@Before
	public void setup(){
		//runs before the test, here it opens the example file with Netlogo Code
		ws = HeadlessWorkspace.newInstance();
		try {
			ws.open("Example.nlogo");
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

	public void test(String input, String expected) {
		//simple function to test the checkCeil reporter in the NetLogo Code
		String actual = Dump.logoObject(ws.report("checkCeil " + input));
		assertEquals(expected, actual);
	}

	@Test
	public void testAdd() {
		String str = "Junit is working fine";
		assertEquals("Junit is working fine",str);
	}

	@Test
	public void same(){
		test("2", "2"); 
	}
	@Test
	public void deci(){
		test("2.5", "3");
	}
	@Test 
	public void longDeci(){
		test("1.38498", "2");
	}
	@Test 
	public void badInput(){
		//this should fail, just example of what could happen
		test("[0.98 2]","[1 2]"); 
	}
}
