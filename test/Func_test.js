const Func = artifacts.require("Func");

contract ('Func tests', async (accounts) => {
    it("should be 15", async () => {
        let func = await Func.deployed();
        let expected = await func.sum(10,5);
        assert.equal(expected.valueOf(), 15);
    });
})

