#include <exception>
#include <memory>
#include <string>

namespace
{
    constexpr int INDEX_WHEREEVER = 0;
    constexpr int FLAG_NOLIMIT = 0;
}// namespace

struct Player
{
    explicit Player(Player *player)
    {
        if (player != nullptr) { *this = *player; }
    }

    static bool getInbox() { return true; }

    static bool isOffline() { return true; }
};

struct Item
{
    static Item *CreateItem(const uint16_t itemId)
    {
        auto item = new Item;
        return item;
    }
};

struct plsCompileForMe
{
    Player *getPlayerByName(const std::string &recipient)
    {
        auto player = new Player(nullptr);
        return player;
    }

    static void internalAddItem(const bool, const Item *item, const uint16_t indexType,
                                const uint16_t flag)
    {
    }
};

struct Game
{
    plsCompileForMe g_game;
    void addItemToPlayer(const std::string &recipient, uint16_t);
    void _addItemToPlayer(const std::string &recipient, uint16_t);
};

namespace IOLoginData
{
    bool loadPlayerByName(const Player *player, const std::string &recipient)
    {
        return true;
    }
    void savePlayer(const Player *player) {}
}// namespace IOLoginData

/*
 * This is how I would fix the memory leak in practice. Wrapping the value in a smart pointer ensures that
 * the resource will always be released without having to manually free the resource (or worry about edge cases
 * like freeing a resource in the case of an exception). You also get clear ownership. I would have preferred
 * wrapping 'player' in a unique pointer, but I don't know where else in the program the player is owned.
 */

void Game::addItemToPlayer(const std::string &recipient, uint16_t itemId)
{
    std::shared_ptr<Player> player(g_game.getPlayerByName(recipient));
    if (!player)
    {
        player = std::make_shared<Player>(nullptr);
        if (!IOLoginData::loadPlayerByName(player.get(), recipient)) { return; }
    }

    std::unique_ptr<Item> item(Item::CreateItem(itemId));
    if (!item) { return; }

    g_game.internalAddItem(player->getInbox(), item.get(), INDEX_WHEREEVER, FLAG_NOLIMIT);
    if (player->isOffline()) { IOLoginData::savePlayer(player.get()); }
}

/*
 * I will include this version just in case the purpose is to show thinking through edge cases
 * rather than just slapping a smart pointer over a raw pointer.
 */

void Game::_addItemToPlayer(const std::string &recipient, uint16_t itemId)
{
    Item *item = nullptr;
    Player *player = nullptr;

    try
    {
        player = g_game.getPlayerByName(recipient);
        if (player)
        {
            player = new Player(nullptr);
            if (!IOLoginData::loadPlayerByName(player, recipient))
            {
                delete player;
                return;
            }
        }

        item = Item::CreateItem(itemId);
        if (!item)
        {
            delete item;
            delete player;
            return;
        }

        g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
        if (player->isOffline()) { IOLoginData::savePlayer(player); }
        delete item;
        delete player;
    }
    catch (...)
    {
        if (item) { delete item; }

        if (player)
        {
            delete player; // I don't like deleting player because it is not clear who owns it, but in the context
                           // of this program, if we don't do it, the resource will leak, so we delete.
        }
    }
}