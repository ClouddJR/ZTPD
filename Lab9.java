import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.runtime.client.EPRuntime;
import com.espertech.esper.runtime.client.EPRuntimeProvider;
import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);

        EPDeployment deployment = compileAndDeploy(epRuntime,
                "select istream data, spolka, kursOtwarcia - min(kursOtwarcia) as roznica from KursAkcji(spolka='Oracle').win:length(2) having kursOtwarcia - min(kursOtwarcia) > 0");

        // Zad24
        // Q: select irstream spolka as X, kursOtwarcia as Y from KursAkcji.win:length(3) where spolka = 'Oracle'
        // Odp: Klauzula where nie ma wpływu na konstruowanie okna. Służy ona tylko do filtrowania wynikowych strumieni ISTREAM oraz RSTREAM.

        // Zad25
        // Q: select irstream data, spolka, kursOtwarcia from KursAkcji.win:length(3) where spolka = 'Oracle'

        // Zad26
        // Q: select irstream data, spolka, kursOtwarcia from KursAkcji(spolka='Oracle').win:length(3)

        // Zad27
        // Q: select istream data, spolka, kursOtwarcia from KursAkcji(spolka='Oracle').win:length(3)

        // Zad28
        // Q: select istream data, spolka, max(kursOtwarcia) from KursAkcji(spolka='Oracle').win:length(5)

        // Zad29
        // Q: select istream data, spolka, kursOtwarcia - max(kursOtwarcia) as roznica from KursAkcji(spolka='Oracle').win:length(5)
        // Odp. Funkcja max w tym przypadku bierze maksymalną wartość z aktualnego okna o rozmiarze 5.

        // Zad30
        // Q: select istream data, spolka, kursOtwarcia - min(kursOtwarcia) as roznica from KursAkcji(spolka='Oracle').win:length(2) having kursOtwarcia - min(kursOtwarcia) > 0
        // Odp: Uzyskane wyniki są poprawne.

        ProstyListener prostyListener = new ProstyListener();

        for (EPStatement statement : deployment.getStatements()) {
            statement.addListener(prostyListener);
        }

        InputStream inputStream = new InputStream();
        inputStream.generuj(epRuntime.getEventService());
    }

    public static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();

        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        EPDeployment deployment;
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            deployment = deploymentService.deploy(epCompiled);
        } catch (EPCompileException e) {
            throw new RuntimeException(e);
        } catch (EPDeployException e) {
            throw new RuntimeException(e);
        }
        return deployment;
    }
}
