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
                "select istream data, spolka, obrot from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) order by obrot desc limit 1 offset 2");

        // Zad5
        // Q: select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica from KursAkcji.win:ext_timed_batch(data.getTime(), 1 day)

        // Zad6
        // Q: select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica from KursAkcji(spolka = 'IBM' or spolka = 'Honda' or spolka = 'Microsoft').win:ext_timed_batch(data.getTime(), 1 day)

        // Zad7a
        // Q: select istream data, spolka, kursOtwarcia, kursZamkniecia from KursAkcji(kursZamkniecia > kursOtwarcia).win:length(1)

        // Zad7b
        // Q: select istream data, spolka, kursOtwarcia, kursZamkniecia from KursAkcji(KursAkcji.czyKursZamknieciaWiekszy(kursOtwarcia, kursZamkniecia) = true).win:length(1)

        // Zad8
        // Q: select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica from KursAkcji(spolka = 'PepsiCo' or spolka = 'CocaCola').win:ext_timed(data.getTime(), 7 days)

        // Zad9
        // Q: select istream data, spolka, kursZamkniecia from KursAkcji(spolka = 'PepsiCo' or spolka = 'CocaCola').win:ext_timed_batch(data.getTime(), 1 day) order by kursZamkniecia desc limit 1

        // Zad10
        // Q: select istream max(kursZamkniecia) as maksimum from KursAkcji().win:ext_timed_batch(data.getTime(), 7 days) order by kursZamkniecia desc limit 1

        // Zad11
        // Q: select istream cc.data, cc.kursZamkniecia as kursCoc, pc.kursZamkniecia as kursPep from KursAkcji(spolka='CocaCola').win:length(1) as cc full outer join KursAkcji(spolka='PepsiCo').win:length(1) as pc on cc.data = pc.data where pc.kursZamkniecia > cc.kursZamkniecia

        // Zad12
        // Q: select istream k.data, k.spolka, k.kursZamkniecia as kursBiezacy, k.kursZamkniecia - a.kursZamkniecia as roznica from KursAkcji(spolka='CocaCola' or spolka='PepsiCo').win:length(1) as k join KursAkcji(spolka='CocaCola' or spolka='PepsiCo').std:firstunique(spolka) as a on k.spolka = a.spolka

        // Zad13
        // Q: select istream k.data, k.spolka, k.kursZamkniecia as kursBiezacy, k.kursZamkniecia - a.kursZamkniecia as roznica from KursAkcji().win:length(1) as k join KursAkcji().std:firstunique(spolka) as a on k.spolka = a.spolka where k.kursZamkniecia > a.kursZamkniecia

        // Zad14
        // Q: select istream k.data as dataA, a.data as dataB, k.spolka, k.kursOtwarcia as kursA, a.kursOtwarcia as kursB from KursAkcji().win:ext_timed(data.getTime(), 7 days) as k join KursAkcji().win:ext_timed(data.getTime(), 7 days) as a on k.spolka = a.spolka where k.kursOtwarcia - a.kursOtwarcia > 3

        // Zad15
        // Q: select istream data, spolka, obrot from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) order by obrot desc limit 3

        // Zad16
        // Q: select istream data, spolka, obrot from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) order by obrot desc limit 1 offset 2

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
