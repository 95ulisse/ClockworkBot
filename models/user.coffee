mongoose = require('mongoose')
Schema = mongoose.Schema

UserSchema = new Schema({
    _id: { type: Number, required: true },
    name: { type: String, required: true, }
    apiKey: { type: String },
    defaultFrom: { type: String }
});

module.exports = mongoose.model('User', UserSchema);
