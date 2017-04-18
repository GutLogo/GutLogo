import org.nlogo.headless.HeadlessWorkspace;
import org.nlogo.*;
public class Example2 {
  public static void main(String[] argv) {
    HeadlessWorkspace workspace = HeadlessWorkspace.newInstance();
    try {
      workspace.open(
	"models/Sample Models/Earth Science/"
	+ "Fire.nlogo");
      workspace.command("set density 62");
      workspace.command("random-seed 0");
      workspace.command("setup");
      workspace.command("repeat 50 [ go ]") ;
      System.out.println(
	workspace.report("burned-trees"));
      workspace.dispose();
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
  }
}
