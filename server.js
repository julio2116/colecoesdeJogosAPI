const sequelize = require('./index');
const { insertData, jogosEColecoes, jogosPorColecao } = require('./seeds/handleData');

require("./models/Colecoes");
require("./models/Jogos");
require("./models/Jogo_colecao");

async function start() {
    try {
        await sequelize.authenticate();
        await sequelize.sync();
        await insertData();
        await jogosEColecoes();
        await jogosPorColecao("RPG Favoritos");
    } catch (error) {
        console.error('Unable to connect to the database:', error);
    }
};

start();