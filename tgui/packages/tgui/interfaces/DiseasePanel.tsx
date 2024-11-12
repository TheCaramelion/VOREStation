import React, { useState } from 'react';

import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type Disease = {
  commonName: string;
  description: string;
  treatment: string;
  transmission: string;
};

type Symptom = {
  name: string;
  stealth: string;
  resistance: string;
  stageSpeed: string;
  transmittable: string;
  severity: string;
};

type Data = {
  infectees: string[];
  diseases: Disease[];
  symptoms: Symptom[];
};

export const DiseasePanel = () => {
  const { data, act } = useBackend<Data>();
  const { diseases, symptoms, infectees } = data;

  const [selectedTab, setSelectedTab] = useState('preset');
  const [selectedDisease, setSelectedDisease] = useState<Disease | null>(null);
  const [selectedSymptoms, setSelectedSymptoms] = useState<Symptom[]>([]);
  const [selectedInfectees, setSelectedInfectees] = useState<string[]>([]);

  const handleReleaseDisease = () => {
    act('release_disease', {
      disease: selectedDisease?.commonName,
      infectees: selectedInfectees,
    });
  };

  return (
    <Window>
      <Window.Content>
        <Section title="Disease Panel">
          <Tabs>
            <Tabs.Tab
              selected={selectedTab === 'preset'}
              onClick={() => setSelectedTab('preset')}
            >
              Preset Diseases
            </Tabs.Tab>
            <Tabs.Tab
              selected={selectedTab === 'custom'}
              onClick={() => setSelectedTab('custom')}
            >
              Create New Disease
            </Tabs.Tab>
          </Tabs>

          {selectedTab === 'preset' && (
            <Section title="Select a Disease">
              <LabeledList>
                {diseases.map((disease) => (
                  <LabeledList.Item
                    key={disease.commonName}
                    label={disease.commonName}
                    buttons={
                      <Button
                        icon="virus"
                        onClick={() => setSelectedDisease(disease)}
                        selected={selectedDisease === disease}
                      >
                        Select
                      </Button>
                    }
                  >
                    {disease.description}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          )}

          {selectedTab === 'custom' && (
            <Section title="Select Symptoms">
              <Table>
                <Table.Row header>
                  <Table.Cell>Symptom</Table.Cell>
                  <Table.Cell>Stealth</Table.Cell>
                  <Table.Cell>Resistance</Table.Cell>
                  <Table.Cell>Stage Speed</Table.Cell>
                  <Table.Cell>Transmissibility</Table.Cell>
                </Table.Row>
                {symptoms.map((symptom) => (
                  <Table.Row key={symptom.name}>
                    <Table.Cell>{symptom.name}</Table.Cell>
                    <Table.Cell>{symptom.stealth}</Table.Cell>
                    <Table.Cell>{symptom.resistance}</Table.Cell>
                    <Table.Cell>{symptom.stageSpeed}</Table.Cell>
                    <Table.Cell>{symptom.transmittable}</Table.Cell>
                    <Table.Cell>
                      <Button
                        icon="plus"
                        onClick={() =>
                          setSelectedSymptoms((prev) =>
                            prev.includes(symptom)
                              ? prev.filter((s) => s !== symptom)
                              : [...prev, symptom],
                          )
                        }
                        selected={selectedSymptoms.includes(symptom)}
                      >
                        {selectedSymptoms.includes(symptom) ? 'Remove' : 'Add'}
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          )}

          <Section title="Select Infectees">
            <LabeledList>
              {infectees.map((infectee) => (
                <LabeledList.Item
                  key={infectee}
                  label={infectee}
                  buttons={
                    <Button
                      icon="user"
                      onClick={() =>
                        setSelectedInfectees((prev) =>
                          prev.includes(infectee)
                            ? prev.filter((inf) => inf !== infectee)
                            : [...prev, infectee],
                        )
                      }
                      selected={selectedInfectees.includes(infectee)}
                    >
                      {selectedInfectees.includes(infectee)
                        ? 'Deselect'
                        : 'Select'}
                    </Button>
                  }
                />
              ))}
            </LabeledList>
          </Section>

          <NoticeBox info>
            {selectedDisease
              ? `Selected Disease: ${selectedDisease.commonName}`
              : 'No disease selected'}
          </NoticeBox>

          <Button
            icon="biohazard"
            onClick={handleReleaseDisease}
            disabled={!selectedDisease && selectedSymptoms.length === 0}
            tooltip="Release the selected disease to chosen infectees."
          >
            Release Disease
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
