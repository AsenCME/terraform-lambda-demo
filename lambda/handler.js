const random = require("random");

module.exports.handler = async () => {
    return {
        statusCode: 200,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: "Works!", number: random.int(0,100) })
    }
}
