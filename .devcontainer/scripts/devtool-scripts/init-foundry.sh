if ! compgen -G "$PROJECT_DIR/foundry.toml" > /dev/null; then
   forge init --no-git --force
else
    echo -e "${GREEN}✓ Existing Foundry project detected${STYLE_END}"
fi