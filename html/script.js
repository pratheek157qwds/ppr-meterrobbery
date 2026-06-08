let currentConfig = {};
let gameTimer = null;
let cards = [];
let flippedCards = [];
let matchedPairs = 0;
let totalPairs = 0;
let isProcessing = false;

window.addEventListener('message', function(event) {
    if (event.data.action === "startMemoryGame") {
        currentConfig = event.data.config;
        startGame();
        $('#game-container').fadeIn(200);
    } 
});

function startGame() {
    $('#game-status').text("SCANNING DATA...").css('color', 'var(--primary)');
    matchedPairs = 0;
    flippedCards = [];
    isProcessing = false;
    
    generateGrid();
    startTimer(currentConfig.TimeLimit);
}

function generateGrid() {
    let rows = currentConfig.GridSize.rows;
    let cols = currentConfig.GridSize.cols;
    totalPairs = (rows * cols) / 2;
    
    // Set Grid CSS
    $('#memory-grid').css({
        'grid-template-columns': `repeat(${cols}, 70px)`,
        'grid-template-rows': `repeat(${rows}, 70px)`
    });

    // Prepare Icon List
    let iconsToUse = currentConfig.Icons.sort(() => 0.5 - Math.random()).slice(0, totalPairs);
    let cardValues = [...iconsToUse, ...iconsToUse]; // Duplicate for pairs
    cardValues.sort(() => 0.5 - Math.random()); // Shuffle

    let board = $('#memory-grid').empty();
    
    cardValues.forEach((iconClass, index) => {
        let card = $(`
            <div class="card" data-id="${index}" data-icon="${iconClass}">
                <div class="card-face card-back"></div>
                <div class="card-face card-front"><i class="fas ${iconClass}"></i></div>
            </div>
        `);
        
        card.click(function() {
            handleCardClick($(this));
        });
        
        board.append(card);
    });
}

function handleCardClick(card) {
    if (isProcessing) return;
    if (card.hasClass('flipped') || card.hasClass('matched')) return;

    card.addClass('flipped');
    flippedCards.push(card);

    if (flippedCards.length === 2) {
        isProcessing = true;
        checkMatch();
    }
}

function checkMatch() {
    let card1 = flippedCards[0];
    let card2 = flippedCards[1];
    let icon1 = card1.data('icon');
    let icon2 = card2.data('icon');

    if (icon1 === icon2) {
        // MATCH FOUND
        card1.addClass('matched');
        card2.addClass('matched');
        matchedPairs++;
        flippedCards = [];
        isProcessing = false;

        if (matchedPairs === totalPairs) {
            winGame();
        }
    } else {
        // NO MATCH
        setTimeout(() => {
            card1.removeClass('flipped');
            card2.removeClass('flipped');
            flippedCards = [];
            isProcessing = false;
        }, 800); // Delay before flipping back
    }
}

function startTimer(seconds) {
    if (gameTimer) clearInterval(gameTimer);
    let total = seconds;
    
    gameTimer = setInterval(() => {
        seconds--;
        let percent = (seconds / total) * 100;
        $('#timer-fill').css('width', percent + '%');
        
        if (seconds <= 0) {
            clearInterval(gameTimer);
            fail();
        }
    }, 1000);
}

function winGame() {
    clearInterval(gameTimer);
    $('#game-status').text("ACCESS GRANTED").css('color', '#32ff7e');
    setTimeout(() => {
        $.post('https://ppr-meter-robbery/win', JSON.stringify({}));
        $('#game-container').fadeOut();
    }, 1000);
}

function fail() {
    $.post('https://ppr-meter-robbery/fail', JSON.stringify({}));
    $('#game-container').fadeOut();
    if(gameTimer) clearInterval(gameTimer);
}