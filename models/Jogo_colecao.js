const { DataTypes, Model } = require('sequelize');
const sequelize = require("../index");

const Jogos = require("./Jogos")
const Colecoes = require("./Colecoes")

class Jogo_colecao extends Model {

}

Jogo_colecao.init(
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },

        jogo_id: {
            type: DataTypes.INTEGER,
            unique: 'uk_jogo_colecao',
            allowNull: false
        },

        colecao_id: {
            type: DataTypes.INTEGER,
            unique: 'uk_jogo_colecao',
            allowNull: false
        },

    },
    {
        sequelize
    }
)

Jogos.belongsToMany(Colecoes, {
    through: Jogo_colecao,
    foreignKey: 'jogo_id',
    otherKey: 'colecao_id',
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE'
});
Colecoes.belongsToMany(Jogos, {
    through: Jogo_colecao,
    foreignKey: 'colecao_id',
    otherKey: 'jogo_id',
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE'
});

module.exports = Jogo_colecao;