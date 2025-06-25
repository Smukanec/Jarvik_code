DIR="$(cd "$(dirname "$0")" && pwd)"

# Add Jarvik aliases only if they aren't already present
if ! grep -q "# 🚀 Alias příkazy pro JARVIK" ~/.bashrc; then
  cat >> ~/.bashrc <<EOF

# 🚀 Alias příkazy pro JARVIK
alias jarvik='bash $DIR/activate.sh'
alias jarvik-start='bash $DIR/start_jarvik_mistral.sh'
alias jarvik-start-7b='bash $DIR/start_Mistral_7B.sh'
alias jarvik-start-q4='bash $DIR/start_Jarvik_Q4.sh'
alias jarvik-status='bash $DIR/status.sh'
alias jarvik-install='bash $DIR/install_jarvik.sh'
alias jarvik-flask='bash $DIR/start_flask.sh'
alias jarvik-model='bash $DIR/start_model.sh'
alias jarvik-ollama='bash $DIR/start_ollama.sh'

EOF
fi

# Načtení změn
source ~/.bashrc
