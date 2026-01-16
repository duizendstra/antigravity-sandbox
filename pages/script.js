document.addEventListener('DOMContentLoaded', () => {
    // Copy to clipboard functionality
    const copyBtn = document.querySelector('.copy-btn');
    const codeBlock = document.querySelector('pre code');

    copyBtn.addEventListener('click', async () => {
        try {
            await navigator.clipboard.writeText(codeBlock.innerText);
            
            // Visual feedback
            const originalIcon = copyBtn.innerHTML;
            copyBtn.innerHTML = `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#238636" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>`;
            copyBtn.style.borderColor = '#238636';
            
            setTimeout(() => {
                copyBtn.innerHTML = originalIcon;
                copyBtn.style.borderColor = '';
            }, 2000);
        } catch (err) {
            console.error('Failed to copy text: ', err);
        }
    });

    // Scroll reveal animation
    const revealElements = document.querySelectorAll('.hero-content, .section h2, .about-text, .feature-card, .code-block, .credential-note');
    
    const revealOnScroll = () => {
        const windowHeight = window.innerHeight;
        const elementVisible = 150;

        revealElements.forEach((element) => {
            const elementTop = element.getBoundingClientRect().top;
            
            if (elementTop < windowHeight - elementVisible) {
                element.classList.add('active');
            }
        });
    };

    // Add reveal class initially
    revealElements.forEach(el => el.classList.add('reveal'));
    
    // Trigger once on load
    revealOnScroll();
    
    // Add event listener
    window.addEventListener('scroll', revealOnScroll);
});
