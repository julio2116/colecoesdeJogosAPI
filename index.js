const { Sequelize } = require('sequelize');

require("dotenv").config()

const {USER, PASSWORD, HOST, PORT, DB} = process.env;

const sequelize = new Sequelize(`postgres://${USER}:${PASSWORD}@${HOST}:${PORT}/${DB}`);

module.exports = sequelize;