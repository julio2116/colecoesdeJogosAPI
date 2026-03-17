const Jogos = require("../models/Jogos");
const Colecoes = require("../models/Colecoes");
const Jogo_colecao = require("../models/Jogo_colecao");

const sequelize = require("../index");

const { jogos, colecoes } = require("./data");

async function insertData() {
    // permite rollback caso pelo menos uma inserção falhe
    const transaction = await sequelize.transaction();

    try {
        // cria coleções
        const colecoesCriadas = await Colecoes.bulkCreate(colecoes, {
            returning: true,
            transaction
        });

        // cria jogos
        const jogosCriados = await Jogos.bulkCreate(jogos, {
            returning: true,
            transaction
        });

        // mapa por nome (seguro)
        const mapaColecoes = {};
        colecoesCriadas.forEach(c => {
            mapaColecoes[c.nome] = c.id;
        });

        const relacoes = [
            "RPG Favoritos",
            "Indies",
            "Backlog",
            "Indies",
            "Backlog",
            "RPG Favoritos",
            "Indies",
            "Backlog",
            "RPG Favoritos",
            "Indies",
            "Backlog",
            "RPG Favoritos",
            "Indies",
            "Backlog",
            "RPG Favoritos",
            "Indies",
            "Backlog",
            "RPG Favoritos",
            "Indies",
            "Backlog",
            "RPG Favoritos"
        ];

        // monta inserts da tabela N:N
        const relacoesInsert = [];

        for (let i = 0; i < jogosCriados.length; i++) {

            const jogo = jogosCriados[i];
            const nomeColecao = relacoes[i];
            const colecaoId = mapaColecoes[nomeColecao];

            if (!colecaoId) {
                throw new Error(`Coleção não encontrada: ${nomeColecao}`);
            }

            relacoesInsert.push({
                jogo_id: jogo.id,
                colecao_id: colecaoId
            });
        }
        // Apenas para verificar multiplas colecoes de um único jogo

        relacoesInsert.push({
            jogo_id: 21,
            colecao_id: 2
        });

        // insert em lote
        await Jogo_colecao.bulkCreate(relacoesInsert, {
            transaction
        });

        await transaction.commit();

    } catch (e) {
        // rollback caso algum dos processos anteriores falhe
        await transaction.rollback();
        throw e;
    }
}

async function jogosEColecoes() {
    try{

        console.log("======= Listando todos os jogos com suas coleções =======");
        // select com join
        const jogosComColecoes = await Jogos.findAll({
            include: {
                model: Colecoes,
                attributes: ['nome', 'descricao'],
                through: { attributes: [] } // remove tabela intermediária
            }
        });
    
        // tratamento para melhor visualização
        for (item of jogosComColecoes) {
            const data = item.dataValues;
            // coleções deve ser um array de elementos, desde que um mesmo jogo pode estar em mais de uma categoria
            const colecoes = { Colecoes: data.Colecoes.map(item => item.dataValues) };
            const newData = Object.assign(data, colecoes);
    
            console.log(newData);
        }
    } catch(e) {
        throw new Error("Erro acessando o banco: " + e.message)
    }
}

async function jogosPorColecao(colecao) {
    if(typeof colecao !== 'string'){
        throw new Error("valor precisa ser uma string")
    };
    try{
        const jogos = await Jogos.findAll({
            include: {
                model: Colecoes,
                where: { nome: colecao },
                attributes: [], // Não seleciona nenhuma coluna de colecao
                through: { attributes: [] }
            }
        });

        for(item of jogos){
            console.log(item.dataValues)
        }
    } catch(e) {
        throw new Error("erro na busca no banco: " + e.message);
    }
}

module.exports = { insertData, jogosEColecoes, jogosPorColecao }