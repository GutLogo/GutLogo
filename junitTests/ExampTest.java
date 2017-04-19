import org.junit.*;
import static org.junit.Assert.assertEquals;

import org.nlogo.headless.HeadlessWorkspace;
import org.nlogo.api.Dump;
import org.nlogo.util.Utils;

public class ExampTest {

	public HeadlessWorkspace ws;

	@Before
	public void setup(){
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
		try {
			ws.dispose();
		}
		catch(Exception ex){
			ex.printStackTrace();
		}
	}

	public void test(String input, String expected) {
		String actual = Dump.logoObject(ws.report("checkCeil " + input));
		assertEquals(expected, actual);
	}

	@Test
	public void testAdd() {
		String str = "Junit is working fine";
		assertEquals("Junit is working fine",str);
	}

	@Test
	public void empty(){
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
		test("[0.98 2]","[1 2]"); 
	}
}
