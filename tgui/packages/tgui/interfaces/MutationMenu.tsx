import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  ProgressBar,
  Section,
  Tabs,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type MutationData = {
  biomass: number;
  max_biomass: number;
  mutations: MutationEntry[];
  categories: string[];
  passive_biomass_gain: number;
  current_caste: string;
};

type MutationEntry = {
  name: string;
  desc: string;
  category: string;
  cost: number;
  icon: string;
  available: boolean;
  purchased: boolean;
  tier: number;
  parent: string | null;
  children: string[];
  unlocked: boolean;
  buff_desc: string;
  caste_restriction?: string[];
};

const categoryIcons: Record<string, string> = {
  Survival: 'shield-alt',
  Offensive: 'fist-raised',
  Specialized: 'magic',
  Enhancement: 'star',
};

const categoryColors: Record<string, string> = {
  Survival: 'good',
  Offensive: 'average',
  Specialized: 'blue',
  Enhancement: 'purple',
};

// Icon overlay styles
const iconOverlayStyles = {
  overlay_purchased: {
    background:
      'linear-gradient(45deg, rgba(0, 255, 0, 0.3), rgba(0, 255, 0, 0.1))',
    borderRadius: '50%',
    boxShadow: '0 0 8px rgba(0, 255, 0, 0.5)',
  },
  overlay_locked: {
    background:
      'linear-gradient(45deg, rgba(255, 0, 0, 0.3), rgba(255, 0, 0, 0.1))',
    borderRadius: '50%',
    boxShadow: '0 0 8px rgba(255, 0, 0, 0.5)',
  },
  overlay_available: {
    background:
      'linear-gradient(45deg, rgba(255, 255, 0, 0.3), rgba(255, 255, 0, 0.1))',
    borderRadius: '50%',
    boxShadow: '0 0 8px rgba(255, 255, 0, 0.5)',
  },
  overlay_no_biomass: {
    background:
      'linear-gradient(45deg, rgba(128, 128, 128, 0.3), rgba(128, 128, 128, 0.1))',
    borderRadius: '50%',
    boxShadow: '0 0 8px rgba(128, 128, 128, 0.5)',
  },
  overlay_orange: {
    background:
      'linear-gradient(45deg, rgba(255, 165, 0, 0.3), rgba(255, 165, 0, 0.1))',
    borderRadius: '50%',
    boxShadow: '0 0 8px rgba(255, 165, 0, 0.5)',
  },
};

export const MutationMenu = (props: any) => {
  const { data } = useBackend<MutationData>();
  const {
    biomass,
    max_biomass,
    categories,
    passive_biomass_gain,
    current_caste,
  } = data;
  const [selectedCategory, setSelectedCategory] = useState<string | null>(
    categories.length ? categories[0] : null,
  );

  return (
    <Window theme="xeno" title="Mutation Menu" width={700} height={600}>
      <Window.Content scrollable>
        <Section
          title="Biomass Status"
          buttons={
            <Button
              tooltip="Гайд на мутации от Фида:
              Мутации с тирами заменяют друг-друга, а не стакаются --
              При эволве ты теряешь все мутации и получаешь биомассу обратно --
              Пси дрейн даёт 5 биомассы тебе и 0.05 пассивного прироста всему хайву --
              Для того чтобы поддерживать пассивный приток биомассы улью нужны генераторы"
            >
              ?
            </Button>
          }
        >
          <Flex align="center">
            <Flex.Item grow={1}>
              <ProgressBar
                ranges={{
                  good: [0.75, Infinity],
                  average: [0.25, 0.75],
                  bad: [-Infinity, 0.25],
                }}
                value={biomass / max_biomass}
                color={biomass >= 12.5 ? 'good' : 'bad'}
              >
                {biomass.toFixed(3)} / {max_biomass} Biomass
              </ProgressBar>
            </Flex.Item>
            <Flex.Item ml={2}>
              <Box
                color={(() => {
                  const gain = (passive_biomass_gain || 0) * 60;
                  if (gain < 0.01) return 'bad'; // красный если 0
                  return 'good'; // зеленый если больше 0
                })()}
                bold
                fontSize="1.2em"
                style={{
                  fontFamily: 'monospace',
                  textShadow: '1px 1px 2px rgba(0,0,0,0.8)',
                }}
              >
                +{((passive_biomass_gain || 0) * 60).toFixed(2)}
              </Box>
            </Flex.Item>
            <Flex.Item ml={1}>
              <Box
                className={classes([
                  'mutationmenu32x32',
                  (passive_biomass_gain || 0) * 60 < 0.01 ? 'wrong' : 'goodd',
                ])}
                style={{
                  transform: 'scale(1.5)',
                }}
              />
            </Flex.Item>
          </Flex>
        </Section>

        {categories.length > 0 && (
          <Section lineHeight={1.75} textAlign="center">
            <Tabs>
              {categories.map((categoryname) => {
                return (
                  <Tabs.Tab
                    key={categoryname}
                    icon={categoryIcons[categoryname]}
                    selected={categoryname === selectedCategory}
                    onClick={() => setSelectedCategory(categoryname)}
                    color={categoryColors[categoryname]}
                  >
                    {categoryname}
                  </Tabs.Tab>
                );
              })}
            </Tabs>
            <Divider />
          </Section>
        )}

        <Mutations selectedCategory={selectedCategory} />
      </Window.Content>
    </Window>
  );
};

const Mutations = (props: { selectedCategory: string | null }) => {
  const { data } = useBackend<MutationData>();
  const { mutations, current_caste } = data;
  const { selectedCategory } = props;

  const filteredMutations = mutations.filter((mutation) => {
    // Filter by category
    if (mutation.category !== selectedCategory) {
      return false;
    }

    // Filter by caste restrictions
    if (mutation.caste_restriction && mutation.caste_restriction.length > 0) {
      return mutation.caste_restriction.includes(current_caste);
    }

    return true;
  });

  // Organize mutations into tree structure
  const mutationMap = new Map<string, MutationEntry>();
  filteredMutations.forEach((mutation) => {
    mutationMap.set(mutation.name, mutation);
  });

  // Find root mutations (no parent)
  const rootMutations = filteredMutations.filter(
    (mutation) => mutation.parent === null,
  );

  return (
    <Section title={`${selectedCategory} Mutations`}>
      {filteredMutations.length === 0 ? (
        <Box
          color={selectedCategory === 'Enhancement' ? 'average' : 'bad'}
          textAlign="center"
        >
          {selectedCategory === 'Enhancement'
            ? 'No enhancement mutations available for your caste.'
            : 'No mutations available in this category!'}
        </Box>
      ) : (
        <Box>
          {rootMutations.map((rootMutation) => (
            <MutationTree
              key={rootMutation.name}
              mutation={rootMutation}
              mutationMap={mutationMap}
              level={0}
            />
          ))}
        </Box>
      )}
    </Section>
  );
};

const MutationTree = (props: {
  mutation: MutationEntry;
  mutationMap: Map<string, MutationEntry>;
  level: number;
}) => {
  const { mutation, mutationMap, level } = props;
  const children = mutation.children
    .map((childName) => mutationMap.get(childName))
    .filter(Boolean) as MutationEntry[];

  // Check if this mutation or any of its descendants are purchased (recursive)
  const hasPurchasedDescendants = (mutation: MutationEntry): boolean => {
    if (mutation.purchased) return true;
    return mutation.children.some((childName) => {
      const child = mutationMap.get(childName);
      return child ? hasPurchasedDescendants(child) : false;
    });
  };

  const isEffectivelyPurchased =
    mutation.purchased || hasPurchasedDescendants(mutation);

  return (
    <Box>
      <MutationNode mutation={mutation} level={level} />
      {children.length > 0 && (
        <Box ml={level * 2} style={{ position: 'relative' }}>
          {/* Vertical line connecting to children */}
          {children.length > 0 && (
            <Box
              style={{
                position: 'absolute',
                left: '-10px',
                top: '0px',
                bottom: '0px',
                width: '2px',
                backgroundColor: isEffectivelyPurchased ? '#00ff00' : '#ff0000',
                zIndex: 1,
              }}
            />
          )}
          {children.map((child, index) => (
            <Box key={child.name} style={{ position: 'relative' }}>
              <MutationTree
                mutation={child}
                mutationMap={mutationMap}
                level={level + 1}
              />
            </Box>
          ))}
        </Box>
      )}
    </Box>
  );
};

const MutationNode = (props: { mutation: MutationEntry; level: number }) => {
  const { mutation, level } = props;
  const { act, data } = useBackend<MutationData>();
  const {
    name,
    desc,
    cost,
    icon,
    available,
    purchased,
    tier,
    unlocked,
    buff_desc,
  } = mutation;

  const canAfford = cost <= data.biomass;

  // Check if a tier 2 or tier 3 mutation is purchased (which would lock the tier 1)
  let isLockedByTier2 = false;
  if (tier === 1) {
    // Check if any tier 2 or tier 3 mutation that depends on this tier 1 is purchased
    const higherTierPurchased = data.mutations.some(
      (m) => (m.tier === 2 || m.tier === 3) && m.parent === name && m.purchased,
    );
    isLockedByTier2 = higherTierPurchased;
  }

  // Check if a tier 3 mutation is purchased (which would lock the tier 2)
  let isLockedByTier3 = false;
  if (tier === 2) {
    // Check if the specific tier 3 mutation that depends on this tier 2 is purchased
    const tier3Purchased = data.mutations.some(
      (m) => m.tier === 3 && m.parent === name && m.purchased,
    );
    isLockedByTier3 = tier3Purchased;
  }

  const canPurchase =
    available &&
    canAfford &&
    !purchased &&
    unlocked &&
    !isLockedByTier2 &&
    !isLockedByTier3;

  // Determine visual state
  let nodeColor = 'bad'; // Red for locked
  if (purchased) {
    nodeColor = 'good'; // Green for purchased
  } else if (isLockedByTier2 || isLockedByTier3) {
    nodeColor = 'bad'; // Red for locked by higher tier
  } else if (unlocked && canPurchase) {
    nodeColor = 'average'; // Yellow for available
  } else if (unlocked) {
    nodeColor = 'blue'; // Blue for unlocked but can't purchase
  }

  // Determine name color
  const getNameColor = () => {
    if (purchased) return 'good'; // Green if purchased
    if (isLockedByTier2 || isLockedByTier3) return 'bad'; // Red if locked by higher tier
    if (unlocked && canAfford) return 'white'; // White if available and can afford
    if (unlocked && !canAfford) return 'orange'; // Orange if unlocked but can't afford
    return 'bad'; // Red if locked
  };

  // Determine icon overlay based on status
  const getIconOverlay = () => {
    if (purchased) return 'overlay_purchased'; // Green checkmark or glow
    if (isLockedByTier2 || isLockedByTier3) return 'overlay_locked'; // Red lock or X
    if (unlocked && canAfford) return null; // No overlay for available mutations
    if (unlocked && !canAfford) return 'overlay_orange'; // Orange for unlocked but can't afford
    return 'overlay_locked'; // Red lock for completely locked
  };

  // Check if a mutation has any purchased descendants (recursive)
  const hasPurchasedDescendants = (mutation: MutationEntry): boolean => {
    if (mutation.purchased) return true;
    return mutation.children.some((childName) => {
      const child = data.mutations.find((m) => m.name === childName);
      return child ? hasPurchasedDescendants(child) : false;
    });
  };

  // Determine line color based on previous tier status
  const getLineColor = () => {
    if (level === 0) return null; // No line for root mutations

    // Find parent mutation (previous tier)
    const parentMutation = data.mutations.find(
      (m) => m.name === mutation.parent,
    );
    if (!parentMutation) return '#ff0000'; // Red if parent not found

    // For tier 2: check if tier 1 is purchased OR has purchased descendants
    if (tier === 2) {
      if (mutation.purchased) return '#00ff00'; // Green if tier 2 purchased
      if (parentMutation.purchased || hasPurchasedDescendants(parentMutation)) {
        return '#666'; // Gray if tier 1 purchased or has descendants
      }
      return '#ff0000'; // Red if tier 1 not purchased
    }

    // For tier 3: check if tier 2 is purchased OR has purchased descendants
    if (tier === 3) {
      if (mutation.purchased) return '#00ff00'; // Green if tier 3 purchased
      if (parentMutation.purchased || hasPurchasedDescendants(parentMutation)) {
        return '#666'; // Gray if tier 2 purchased or has descendants
      }
      return '#ff0000'; // Red if tier 2 not purchased
    }

    // Default logic for other cases
    if (parentMutation.purchased) return '#00ff00'; // Green if parent purchased
    if (parentMutation.unlocked) return '#666'; // Gray if parent available
    return '#ff0000'; // Red if parent locked
  };

  // Calculate line position and width based on tier
  const getLinePosition = () => {
    switch (tier) {
      case 1:
        return '-12px'; // Standard position
      case 2:
        return '-16px'; // Adjusted for new margin
      case 3:
        return '-24px'; // Adjusted for new margin
      default:
        return '-12px';
    }
  };

  const getLineWidth = () => {
    switch (tier) {
      case 1:
        return '20px'; // From vertical line to icon
      case 2:
        return '20px'; // From vertical line to icon
      case 3:
        return '25px'; // Longer for tier 3 to reach icon
      default:
        return '20px';
    }
  };

  const lineColor = getLineColor();
  const lineWidth = getLineWidth();
  const linePosition = getLinePosition();

  return (
    <Box
      mb={1}
      p={1.5}
      backgroundColor="rgba(0, 0, 0, 0.3)"
      borderRadius="4px"
      border={`2px solid ${nodeColor === 'good' ? '#00ff00' : nodeColor === 'average' ? '#ffff00' : nodeColor === 'blue' ? '#0080ff' : '#ff0000'}`}
      style={{
        marginLeft: `${level === 1 ? 12 : level === 2 ? 20 : level * 8}px`,
        position: 'relative',
        opacity: purchased || canPurchase || (unlocked && !canAfford) ? 1 : 0.5, // Full opacity for purchased/available/unlocked, dimmed for locked
        minHeight: '80px',
      }}
    >
      {/* Connection line to parent */}
      {level > 0 && lineColor && (
        <Box
          style={{
            position: 'absolute',
            left: linePosition,
            top: '50%',
            width: lineWidth,
            height: '2px',
            backgroundColor: lineColor,
            zIndex: 1,
          }}
        />
      )}

      <Flex align="center">
        <Flex.Item>
          <Box
            ml={2}
            mr={6}
            style={{
              transform: 'scale(2)',
              position: 'relative',
              display: 'inline-block',
              overflow: 'hidden',
            }}
          >
            {/* Base icon */}
            <Box
              className={classes(['mutationmenu32x32', icon])}
              style={{
                position: 'relative',
                zIndex: 1,
              }}
            />
            {/* Status overlay */}
            {getIconOverlay() && (
              <Box
                style={{
                  position: 'absolute',
                  top: 0,
                  left: 0,
                  zIndex: 2,
                  width: '32px',
                  height: '32px',
                  ...iconOverlayStyles[getIconOverlay()!],
                }}
              />
            )}
          </Box>
        </Flex.Item>
        <Flex.Item grow={1}>
          <Flex align="center" mb={1}>
            <Flex.Item grow={1}>
              <Box bold fontSize="1.4em" color={getNameColor()}>
                {name}
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Box
                color={
                  purchased
                    ? 'good'
                    : !unlocked || isLockedByTier2 || isLockedByTier3
                      ? 'bad'
                      : !canAfford
                        ? 'label'
                        : 'good'
                }
                fontSize="1.5em"
                bold
                style={{
                  fontFamily: 'monospace',
                  display: 'flex',
                  alignItems: 'center',
                  marginTop: '2px',
                }}
              >
                {purchased
                  ? ''
                  : isLockedByTier2 || isLockedByTier3
                    ? 'LOCKED'
                    : `${cost}`}
              </Box>
            </Flex.Item>
            <Flex.Item ml={1}>
              <Button
                disabled={
                  !canPurchase &&
                  !(!unlocked || isLockedByTier2 || isLockedByTier3)
                }
                color={
                  purchased
                    ? 'good'
                    : !unlocked || isLockedByTier2 || isLockedByTier3
                      ? 'bad'
                      : !canAfford
                        ? 'label'
                        : 'good'
                }
                width="70px"
                style={
                  !unlocked || isLockedByTier2 || isLockedByTier3
                    ? { backgroundColor: 'var(--color-bad) !important' }
                    : {}
                }
                onClick={() =>
                  act('purchase_mutation', { mutation_name: name })
                }
                tooltip={
                  !unlocked
                    ? 'Locked - requires parent mutation'
                    : isLockedByTier2
                      ? 'Locked - tier 2 mutation purchased'
                      : isLockedByTier3
                        ? 'Locked - tier 3 mutation purchased'
                        : !available
                          ? 'Not available'
                          : !canAfford
                            ? 'Not enough biomass'
                            : purchased
                              ? 'Already purchased'
                              : 'Purchase this mutation'
                }
              >
                {purchased
                  ? ''
                  : isLockedByTier2 || isLockedByTier3
                    ? 'Locked'
                    : unlocked
                      ? 'Purchase'
                      : 'Locked'}
              </Button>
            </Flex.Item>
          </Flex>
          <Divider mb={0.5} />
          <Box fontSize="1em" color="white" mt={1.8}>
            {desc}
          </Box>
          {buff_desc && (
            <Box fontSize="0.9em" color="label" mt={0.8}>
              • {buff_desc}
            </Box>
          )}
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const MutationEntryComponent = (props: { mutation: MutationEntry }) => {
  const { act, data } = useBackend<MutationData>();
  const { mutation } = props;
  const {
    name,
    desc,
    cost,
    icon,
    available,
    purchased,
    buff_desc,
    tier,
    unlocked,
  } = mutation;

  const canAfford = cost <= data.biomass;

  // Check if a tier 2 or tier 3 mutation is purchased (which would lock the tier 1)
  let isLockedByTier2 = false;
  if (tier === 1) {
    // Check if any tier 2 or tier 3 mutation that depends on this tier 1 is purchased
    const higherTierPurchased = data.mutations.some(
      (m) => (m.tier === 2 || m.tier === 3) && m.parent === name && m.purchased,
    );
    isLockedByTier2 = higherTierPurchased;
  }

  // Check if a tier 3 mutation is purchased (which would lock the tier 2)
  let isLockedByTier3 = false;
  if (tier === 2) {
    // Check if the specific tier 3 mutation that depends on this tier 2 is purchased
    const tier3Purchased = data.mutations.some(
      (m) => m.tier === 3 && m.parent === name && m.purchased,
    );
    isLockedByTier3 = tier3Purchased;
  }

  const canPurchase =
    available &&
    canAfford &&
    !purchased &&
    !isLockedByTier2 &&
    !isLockedByTier3;

  return (
    <Collapsible
      title={
        <Flex align="center">
          <Flex.Item>
            <Box
              className={classes(['mutationmenu32x32', icon])}
              ml={2}
              mr={6}
              style={{
                transform: 'scale(1.8)',
                overflow: 'hidden',
              }}
            />
          </Flex.Item>
          <Flex.Item grow={1}>
            <Box bold fontSize="1.4em">
              {name}
            </Box>
          </Flex.Item>
          <Flex.Item>
            <Box
              color={
                purchased
                  ? 'good'
                  : !unlocked || isLockedByTier2 || isLockedByTier3
                    ? 'bad'
                    : !canAfford
                      ? 'label'
                      : 'good'
              }
              fontSize="1.1em"
              bold
              style={{
                fontFamily: 'monospace',
                display: 'flex',
                alignItems: 'center',
                marginTop: '2px',
              }}
            >
              {purchased
                ? 'PURCHASED'
                : isLockedByTier2 || isLockedByTier3
                  ? 'LOCKED'
                  : `${cost}`}
            </Box>
          </Flex.Item>
        </Flex>
      }
      buttons={
        <Button
          mr={1}
          disabled={
            !canPurchase && !(!unlocked || isLockedByTier2 || isLockedByTier3)
          }
          color={
            purchased
              ? 'good'
              : !unlocked || isLockedByTier2 || isLockedByTier3
                ? 'bad'
                : !canAfford
                  ? 'label'
                  : 'good'
          }
          width="70px"
          style={
            !unlocked || isLockedByTier2 || isLockedByTier3
              ? { backgroundColor: 'var(--color-bad) !important' }
              : {}
          }
          onClick={() => act('purchase_mutation', { mutation_name: name })}
          tooltip={
            !available
              ? 'Not available'
              : isLockedByTier2
                ? 'Locked - tier 2 mutation purchased'
                : isLockedByTier3
                  ? 'Locked - tier 3 mutation purchased'
                  : !canAfford
                    ? 'Not enough biomass'
                    : purchased
                      ? 'Already purchased'
                      : 'Purchase this mutation'
          }
        >
          {purchased
            ? ''
            : isLockedByTier2 || isLockedByTier3
              ? 'Locked'
              : 'Purchase'}
        </Button>
      }
    >
      <Box p={2}>
        <Box bold fontSize="1.2em" mb={1}>
          {name}
        </Box>
        <Divider mb={1} />
        <Box mb={2} italic>
          {desc}
        </Box>
        <Divider />
        <Flex align="center" mt={2}>
          <Flex.Item grow={1}>
            <Box>
              <Box bold color="label">
                Requirements:
              </Box>
              {purchased && (
                <Box color="good" bold>
                  • Already Owned
                </Box>
              )}
            </Box>
          </Flex.Item>
        </Flex>
        {purchased && (
          <Box
            mt={2}
            p={1}
            backgroundColor="rgba(0, 255, 0, 0.1)"
            textAlign="center"
          >
            <Box bold color="good">
              ✓ This mutation is already active!
            </Box>
          </Box>
        )}
      </Box>
    </Collapsible>
  );
};
