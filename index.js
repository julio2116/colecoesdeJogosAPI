const sequelize = require('./config');
const handleData = require('./seeds/handleData');

require("./models/Colecoes");
require("./models/Jogos");
require("./models/Jogo_colecao");

class App {

    async start() {
        try {
            await sequelize.authenticate();
            await sequelize.sync();

            console.log('\n\n============== Inserindo dados em lote ==============\n\n')
            await handleData.insertData();
            
            console.log('\n\n============== Listando todos os jogos com suas coleções ==============\n\n');
            await handleData.jogosEColecoes();

            console.log('\n\n============== Listando jogos por coleção ==============\n\n')
            await handleData.jogosPorColecao("RPG Favoritos");

            console.log('\n\n============== Listagem com filtro ==============\n\n')
            await handleData.mostrarTopJogos(['avaliacao', 'DESC'], ['data_fim', 'DESC']); // Este formato possibilita passagem de multiplas ordenações

            console.log('\n\n============== verifica jogo hades com status "NÃO INICIADO" e depois "JOGANDO" ==============\n\n');
            await handleData.encontrarPorTitulo("Hades");
            await handleData.atualizarStatusJogo("JOGANDO", { titulo: "Hades" });
            await handleData.encontrarPorTitulo("Hades");

            console.log('\n\n============== Deletando item Outer Wilds ==============\n\n')
            await handleData.deletarJogoPorTitulo("Outer Wilds");
        } catch (error) {
            console.error('Unable to connect to the database:', error);
        }
    }
}

const app = new App();
app.start();