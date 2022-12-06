const findProduct = (input: number[], target) => {
	let product = 0;
	input.some((num) => {
		const otherNum = target - num;
		const otherNumIndex = input.indexOf(otherNum);
		if (otherNumIndex > -1) {
			product = num * otherNum;
			return true;
		}
		return false;
	});
	return product;
};

const findTripleSumProduct = (input: number[], target: number) => {
	let product = 0;
	input.sort().some((a, index) => {
		const slicedArr = input.slice(index + 1);
		product = a * findProduct(slicedArr, target - a);
		return product;
	});
	return product;
};

// https://codesandbox.io/s/ecstatic-sinoussi-tgmi1?file=/src/index.ts