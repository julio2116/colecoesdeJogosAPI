const sequelize = require('./index');

require("./models/Colecoes")
require("./models/Jogos")
require("./models/Jogo_colecao")

async function start(){
  try {
    await sequelize.authenticate();
    await sequelize.sync();
    console.log('Connection has been established successfully.');
  } catch (error) {
    console.error('Unable to connect to the database:', error);
  }
};

start();