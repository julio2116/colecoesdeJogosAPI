const { DataTypes, Model } = require('sequelize');
const sequelize = require("../index");

class Colecoes extends Model {

}

Colecoes.init(
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },

        nome: {
            type: DataTypes.STRING(100),
            unique: true
        },
        descricao: {
            type: DataTypes.STRING(200)
        },
    },
    {
        sequelize
    }
);

module.exports = Colecoes;