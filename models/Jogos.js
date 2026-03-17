const { DataTypes, Model } = require('sequelize');
const sequelize = require("../index");

class Jogos extends Model {
    isPositive() {
        if (this.horas_jogadas < 0) throw new Error("Horas não pode ser menor que 0");
    }

    BiggerThan() {
        if (this.data_fim < this.data_inicio) throw new Error("Data inicio não pode ser maior que data fim")
    }

}

Jogos.init(
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },

        titulo: {
            type: DataTypes.STRING(100),
            unique: 'uk_titulo_plataforma'
        },

        genero: {
            type: DataTypes.STRING(100)
        },

        plataforma: {
            type: DataTypes.STRING(50),
            unique: 'uk_titulo_plataforma'
        },

        horas_jogadas: {
            type: DataTypes.FLOAT,
            validate: {
                validarPositivo() {
                    this.isPositive();
                }
            }
        },

        status: {
            type: DataTypes.ENUM('NÃO INICIADO', 'JOGANDO', 'FINALIZADO'),
            defaultValue: 'NÃO INICIADO'
        },

        avaliacao: {
            type: DataTypes.INTEGER,
            validate: {
                min: 0,
                max: 10
            }
        },

        data_inicio: {
            type: DataTypes.DATE
        },

        data_fim: {
            type: DataTypes.DATE
        },

        ano_lancamento: {
            type: DataTypes.INTEGER,
        },
    },
    {
        sequelize,
        validate: {
            endDateLessThanStart() {
                this.BiggerThan();
            }
        }
    },
);

module.exports = Jogos;