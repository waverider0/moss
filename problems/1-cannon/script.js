function checkAnswer() {
        const input = document.getElementById("answer");
        const btn = document.getElementById("solution-btn");
        const value = parseFloat(input.value);
        const correct = Math.abs(value - 100) <= 1; // placeholder

        input.classList.remove("correct", "incorrect");
        void input.offsetWidth; // restart animation

        input.classList.add(correct ? "correct" : "incorrect");
        btn.style.display = "inline-block";
}

function toggleSolution() {
        const section = document.getElementById("solution-section");
        const btn = document.getElementById("solution-btn");
        const shown = section.style.display === "block";

        section.style.display = shown ? "none" : "block";
        btn.textContent = shown ? "Show Solution" : "Hide Solution";
}

document.getElementById("answer").addEventListener("keypress", e => {
        if (e.key === "Enter") checkAnswer();
});