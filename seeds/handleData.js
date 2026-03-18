const Jogos = require("../models/Jogos");
const Colecoes = require("../models/Colecoes");
const Jogo_colecao = require("../models/Jogo_colecao");

const sequelize = require("../config");

const { jogos, colecoes } = require("./data");

class HandleData {

    async insertData() {
        const transaction = await sequelize.transaction();

        try {
            const colecoesCriadas = await Colecoes.bulkCreate(colecoes, {
                returning: true,
                transaction
            });

            const jogosCriados = await Jogos.bulkCreate(jogos, {
                returning: true,
                transaction
            });

            const mapaColecoes = {};
            colecoesCriadas.forEach(c => {
                mapaColecoes[c.nome] = c.id;
            });

            const relacoes = [
                "RPG Favoritos", "Indies", "Backlog", "Indies", "Backlog",
                "RPG Favoritos", "Indies", "Backlog", "RPG Favoritos", "Indies",
                "Backlog", "RPG Favoritos", "Indies", "Backlog", "RPG Favoritos",
                "Indies", "Backlog", "RPG Favoritos", "Indies", "Backlog", "RPG Favoritos"
            ];

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

            relacoesInsert.push({
                jogo_id: 21,
                colecao_id: 2
            });

            await Jogo_colecao.bulkCreate(relacoesInsert, {
                transaction
            });

            await transaction.commit();

        } catch (e) {
            await transaction.rollback();
            throw new Error("Erro ao inserir dados, rollback ativado, " + e);
        }
    }

    async jogosEColecoes() {
        try {
            const jogosComColecoes = await Jogos.findAll({
                include: {
                    model: Colecoes,
                    attributes: ['nome', 'descricao'],
                    through: { attributes: [] }
                }
            });

            for (let item of jogosComColecoes) {
                const data = item.dataValues;
                const colecoes = { Colecoes: data.Colecoes.map(i => i.dataValues) };
                const newData = Object.assign(data, colecoes);

                console.log(newData);
            }

        } catch (e) {
            throw new Error("Erro acessando o banco: " + e.message);
        }
    }

    async jogosPorColecao(colecao) {
        if (typeof colecao !== 'string') {
            throw new Error("valor precisa ser uma string");
        }

        try {
            const jogos = await Jogos.findAll({
                include: {
                    model: Colecoes,
                    where: { nome: colecao },
                    attributes: [],
                    through: { attributes: [] }
                }
            });

            for (let item of jogos) {
                console.log(item.dataValues);
            }

        } catch (e) {
            throw new Error("erro na busca no banco: " + e.message);
        }
    }

    async encontrarPorTitulo(titulo) {
        try {
            const jogo = await Jogos.findOne({ where: { titulo } });

            if (jogo === null) {
                console.log('Not found!');
                return;
            }

            console.log(jogo.dataValues);

        } catch (e) {
            throw new Error("Erro ao acessar o banco: " + e.message);
        }
    }

    async atualizarStatusJogo(status, termo) {
        const transaction = await sequelize.transaction();

        try {
            const [linhasAfetadas] = await Jogos.update(
                {
                    status,
                    horas_jogadas: 200
                },
                {
                    where: termo,
                    transaction
                }
            );

            if (linhasAfetadas === 0) {
                throw new Error("Nenhum jogo foi atualizado");
            }

            await transaction.commit();

        } catch (e) {
            await transaction.rollback();
            throw new Error("Erro ao atualizar, rollback ativado, " + e);
        }
    }

    async mostrarTopJogos(order) {
        try {
            const jogos = await Jogos.findAll({
                where: {
                    status: "NÃO INICIADO"
                },
                order: [
                    order
                ],
                limit: 10
            });

            if (!jogos || jogos.length === 0) {
                throw new Error("Nenhum jogo encontrado");
            }

            console.log(jogos.map(item => item.dataValues));

        } catch (e) {
            throw e;
        }
    }

    async deletarJogoPorTitulo(titulo) {
        const transaction = await sequelize.transaction();

        try {
            const linhasRemovidas = await Jogos.destroy({
                where: { titulo },
                transaction
            });

            if (linhasRemovidas === 0) {
                throw new Error("Nenhum registro foi removido");
            }

            await transaction.commit();

            console.log(linhasRemovidas);

        } catch (e) {
            await transaction.rollback();
            throw e;
        }
    }
}

module.exports = new HandleData();