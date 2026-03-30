cd /Users/jonathan_m_barney/CAAP
rm -rf .git
git init
git add .
git commit -m "Initial submission of Contextual Agent Authorization Mesh (CAAM)"
# Then force push to overwrite the remote repository history:
git remote add origin https://github.com/jmbarney5/Contextual-Agent-Authorization-Mesh.git
git push -u --force origin main
