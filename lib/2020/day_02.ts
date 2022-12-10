const isValid = (str: string, char: string, min: number, max: number) => {
	const letterFrequency = (str.match(new RegExp(char, "gi")) || []).length;
	return letterFrequency >= min && letterFrequency <= max;
};

const isValidPartTwo = (
	str: string,
	char: string,
	first: number,
	second: number
) => {
	const res1 = str[first - 1] === char;
	const res2 = str[second - 1] === char;

	if (res1 && res2) return false;
	if (!res1 && !res2) return false;
	return true;
};

const getValidPaswords = (input: string[]) => {
	let validPasswords = 0;
	let validPasswordsPartTwo = 0;
	input.forEach((line) => {
		const [counts, letter, password] = line.split(" ");
		const [start, end] = counts.split("-");

		if (isValid(password, letter.slice(0, -1), Number(start), Number(end)))
			validPasswords += 1;
		if (
			isValidPartTwo(
				password,
				letter.slice(0, -1),
				Number(start),
				Number(end)
			)
		)
			validPasswordsPartTwo += 1;
	});

	return [validPasswords, validPasswordsPartTwo];
};

// https://codesandbox.io/s/agitated-mcnulty-vsohb?file=/src/index.ts